require 'fileutils'

# Google ML Kit (yuzni aniqlash) iOS simulyatori uchun arm64 bo'lagini bermaydi:
# kutubxonalarda faqat qurilma uchun arm64 va simulyator uchun x86_64 bor,
# podspec esa simulyatorda arm64 ni butunlay o'chiradi (EXCLUDED_ARCHS).
# Apple Silicon Mac'dagi iOS 27 simulyatori x86_64 ilovani ishga tushirmaydi,
# shuning uchun ilova simulyatorda umuman yig'ilmasdi
# ("Framework 'Pods_Runner' not found").
#
# Yechim faqat simulyator yig'ilishi uchun: ML Kit kutubxonalarining nusxasi
# olinadi, undagi arm64 obyektlarning platforma belgisi iOS -> iOS Simulator
# qilib almashtiriladi va simulyator yig'ilishi shu nusxaga bog'lanadi.
# Haqiqiy iPhone yig'ilishi asl kutubxonalarni ishlatadi — unga ta'sir yo'q.
module MlkitSimulator
  FRAMEWORKS = %w[MLImage MLKitCommon MLKitVision MLKitFaceDetection].freeze
  SIM_DIR = 'FrameworksSimulator'.freeze
  DIR_VAR = 'GOHOTEL_MLKIT_FRAMEWORKS_DIR'.freeze

  MH_MAGIC_64 = 0xfeedfacf
  CPU_TYPE_ARM64 = 0x0100000c
  LC_BUILD_VERSION = 0x32
  LC_VERSION_MIN_IPHONEOS = 0x25
  PLATFORM_IOS = 2
  PLATFORM_IOSSIMULATOR = 7

  # Nusxa olishda nimadir o'xshamasa (masalan ML Kit yangilanib, tuzilishi
  # o'zgarsa) — ogohlantiriladi va hech narsa o'zgartirilmaydi: qurilma
  # yig'ilishi hech qachon shu sabab bilan buzilmaydi.
  def self.apply(installer)
    pods = installer.sandbox.root.to_s
    names = FRAMEWORKS.select { |n| File.file?(source_binary(pods, n)) }
    return if names.empty?

    begin
      names.each { |n| build_simulator_copy(pods, n) }
    rescue StandardError => e
      Pod::UI.warn "ML Kit simulyator nusxasi tayyorlanmadi (#{e.message}) — ilova simulyatorda yig'ilmaydi, iPhone'ga ta'sir yo'q"
      return
    end
    Dir.glob(File.join(pods, 'Target Support Files', '*', '*.xcconfig')).each do |path|
      rewrite_xcconfig(path, names)
    end
  end

  def self.source_binary(pods, name)
    File.join(pods, name, 'Frameworks', "#{name}.framework", name)
  end

  # Pods/<nom>/FrameworksSimulator/<nom>.framework: sarlavhalar o'sha,
  # binar fayl = x86_64 + "simulyator" deb belgilangan arm64.
  def self.build_simulator_copy(pods, name)
    src_fw = File.dirname(source_binary(pods, name))
    src_bin = source_binary(pods, name)
    dst_dir = File.join(pods, name, SIM_DIR)
    dst_fw = File.join(dst_dir, "#{name}.framework")
    dst_bin = File.join(dst_fw, name)
    stamp_path = File.join(dst_dir, '.source')
    stamp = "v1-#{File.size(src_bin)}-#{File.mtime(src_bin).to_i}"
    return if File.file?(dst_bin) && File.file?(stamp_path) && File.read(stamp_path) == stamp

    archs = IO.popen(['xcrun', 'lipo', '-archs', src_bin], &:read).split
    raise "#{name}: arm64 bo'lagi yo'q (#{archs.join(' ')})" unless archs.include?('arm64')

    FileUtils.rm_rf(dst_dir)
    FileUtils.mkdir_p(dst_dir)
    FileUtils.cp_r(src_fw, dst_dir)
    slices = archs.map do |arch|
      slice = "#{dst_bin}.#{arch}"
      lipo('-thin', arch, src_bin, '-output', slice)
      slice
    end

    arm64 = "#{dst_bin}.arm64"
    data = File.binread(arm64)
    result = mark_as_simulator!(data)
    unless result[:unsupported].zero?
      Pod::UI.warn "ML Kit #{name}: #{result[:unsupported]} ta obyekt eski formatda — simulyatorda bog'lanmasligi mumkin"
    end
    File.binwrite(arm64, data)

    lipo('-create', *slices, '-output', dst_bin)
    FileUtils.rm_f(slices)
    File.write(stamp_path, stamp)
  end

  def self.lipo(*args)
    system('xcrun', 'lipo', *args) || raise("lipo #{args.first(2).join(' ')} bajarilmadi")
  end

  # Yagona Mach-O obyekt yoki statik kutubxona (ar arxivi) ichidagi har bir
  # arm64 obyektda LC_BUILD_VERSION platformasi iOS -> iOS Simulator.
  def self.mark_as_simulator!(data)
    result = { patched: 0, unsupported: 0 }
    if data.start_with?("!<arch>\n")
      pos = 8
      while pos + 60 <= data.bytesize
        header = data.byteslice(pos, 60)
        name = header[0, 16].strip
        size = header[48, 10].to_i
        body = pos + 60
        name_len = name.start_with?('#1/') ? name[3..].to_i : 0
        patch_object!(data, body + name_len, result)
        pos = body + size
        pos += 1 if pos.odd?
      end
    else
      patch_object!(data, 0, result)
    end
    result
  end

  def self.patch_object!(data, offset, result)
    return if offset + 32 > data.bytesize

    magic, cputype, _subtype, _filetype, ncmds = data.byteslice(offset, 20).unpack('V5')
    return unless magic == MH_MAGIC_64 && cputype == CPU_TYPE_ARM64

    cmd_pos = offset + 32
    ncmds.times do
      cmd, cmdsize = data.byteslice(cmd_pos, 8).unpack('VV')
      if cmd == LC_BUILD_VERSION
        if data.byteslice(cmd_pos + 8, 4).unpack1('V') == PLATFORM_IOS
          data[cmd_pos + 8, 4] = [PLATFORM_IOSSIMULATOR].pack('V')
          result[:patched] += 1
        end
      elsif cmd == LC_VERSION_MIN_IPHONEOS
        result[:unsupported] += 1
      end
      cmd_pos += cmdsize
    end
  end

  # Simulyator yig'ilishi: arm64 taqiqi olib tashlanadi va ML Kit
  # kutubxonalari papkasi o'zgaruvchiga aylanadi — qurilmada "Frameworks"
  # (avvalgidek), simulyatorda "FrameworksSimulator". Ikkinchi
  # FRAMEWORK_SEARCH_PATHS[sdk=...] qatori bo'lmaydi: uning $(inherited)'i
  # asl yo'lni ham olib kelib, birinchi o'ringa qo'yardi.
  def self.rewrite_xcconfig(path, names)
    text = File.read(path)
    original = text.dup
    text = text.gsub(/^EXCLUDED_ARCHS\[sdk=iphonesimulator\*\] = arm64\n/, '')
    unless text.include?(DIR_VAR)
      text = text.sub(/^FRAMEWORK_SEARCH_PATHS = (.*)$/) do |line|
        new_line = names.reduce(line) do |acc, n|
          acc.gsub(%("${PODS_ROOT}/#{n}/Frameworks"), %("${PODS_ROOT}/#{n}/$(#{DIR_VAR})"))
        end
        next line if new_line == line

        "#{DIR_VAR} = Frameworks\n#{DIR_VAR}[sdk=iphonesimulator*] = #{SIM_DIR}\n#{new_line}"
      end
    end
    File.write(path, text) unless text == original
  end
end
