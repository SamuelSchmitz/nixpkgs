{ lib, stdenv, fetchFromGitHub, cmake, git, mongoc, python310, boost }:
stdenv.mkDerivation rec {
  pname = "mongo-cxx-driver";
  version = "3.7.0";

  src = fetchFromGitHub {
    owner = "mongodb";
    repo = "mongo-cxx-driver";
    rev = "r${version}";
    sha256 = "sha256-cvPBv7965URAfhxg6hl/mLBApiLVG7FPP+mzJBebkzU=";
  };

  cmakeFlags = ["-DCMAKE_BUILD_TYPE=Release" "-DBUILD_VERSION=${version}" "-DCMAKE_CXX_STANDARD=17" "-DBSONCXX_POLY_USE_BOOST=1"];

  nativeBuildInputs = [cmake python310 git mongoc boost];

  #doCheck = false;
  #enableParallelChecking = false;
  enableParallelBuilding = true;

  # mongoc's cmake incorrectly injects a prefix to library paths, breaking Nix. This removes the prefix from paths.
  postPatch = ''
    substituteInPlace src/mongocxx/config/CMakeLists.txt \
      --replace "\\\''${prefix}/" ""
    substituteInPlace src/bsoncxx/config/CMakeLists.txt \
      --replace "\\\''${prefix}/" ""
  '';

  meta = {
    description = "The official C++ client library for MongoDB";
    homepage = "https://www.mongodb.com/docs/drivers/cxx/";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
