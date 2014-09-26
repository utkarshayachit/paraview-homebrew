require 'formula'

class Paraview < Formula
  url "http://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v4.2&type=source&os=all&downloadFile=ParaView-v4.2.0-source.tar.gz"
  version "4.2.0"
  sha1 "77cf0e3804eb7bb91d2d94b10bd470f4"
  homepage 'http://paraview.org'

  # 'head' release URL
  head "git://paraview.org/ParaView.git", :using => :git, :tag => "master"

  depends_on 'cmake' => :build

  # Core dependencies. If any of these are off, they are OFF!
  depends_on :mpi => [:cc, :cxx, :optional] # Is optional. MPI with `cc` and `cxx`.
  depends_on :python => :recommended
  depends_on 'qt' => :recommended
  depends_on 'ffmpeg' => :recommended
  depends_on 'cgns' => :recommended
  depends_on 'boost' => :recommended

  # Python module dependencies  
  depends_on 'matplotlib' => [:python, :optional]

  # Builtin dependencies. If any of these are off, we build our own.
  depends_on :libpng => :recommended
  depends_on :freetype => :optional
  depends_on :fontconfig => :optional
  depends_on 'jpeg' => :optional
  depends_on 'libtiff' => :optional
  depends_on 'hdf5' => :recommended

  def install
    args = std_cmake_args + %W[
      -DBUILD_SHARED_LIBS=ON
      -DBUILD_TESTING=OFF
      -DVTK_USE_SYSTEM_EXPAT=ON
      -DVTK_USE_SYSTEM_LIBXML2=ON
      -DVTK_USE_SYSTEM_ZLIB=ON
      -DPARAVIEW_DO_UNIX_STYLE_INSTALLS:BOOL=OFF
      -DMACOSX_APP_INSTALL_PREFIX:PATH=#{prefix}
    ]

    # enable/disable Qt support
    if build.with? 'qt'
      args << '-DPARAVIEW_BUILD_QT_GUI:BOOL=ON'
    else
      args << '-DPARAVIEW_BUILD_QT_GUI:BOOL=OFF'
    end

    args << '-DPARAVIEW_USE_MPI:BOOL=ON' if build.with? :mpi
    args << '-DPARAVIEW_ENABLE_FFMPEG:BOOL=ON' if build.with? 'ffmpeg'
    args << '-DVTK_USE_SYSTEM_FREETYPE=ON' if build.with? :freetype
    args << '-DVTK_USE_SYSTEM_HDF5=ON' if build.with? 'hdf5'
    args << '-DVTK_USE_SYSTEM_JPEG=ON' if build.with? 'jpeg'
    args << '-DVTK_USE_SYSTEM_PNG=ON' if build.with? :libpng
    args << '-DVTK_USE_SYSTEM_TIFF=ON' if build.with? 'libtiff'
    args << '-DPARAVIEW_USE_VISITBRIDGE:BOOL=ON' if build.with? 'boost'
    args << '-DVISIT_BUILD_READER_CGNS:BOOL=ON' if build.with? 'cgns'
    mkdir 'build' do
      # enable/disable Python support
      if build.with? "python"
        args << '-DPARAVIEW_ENABLE_PYTHON:BOOL=ON'
        # CMake picks up the system's python dylib, even if we have a brewed one.
        args << "-DPYTHON_LIBRARY='#{%x(python-config --prefix).chomp}/lib/libpython2.7.dylib'"
      else
        args << '-DPARAVIEW_ENABLE_PYTHON:BOOL=OFF'
      end
      args << ".."

      system 'cmake', *args
      system 'make'
      system 'make', 'install'
    end
  end

  test do
    system "#{prefix}/paraview.app/Contents/MacOS/paraview --version"
  end
end
