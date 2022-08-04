CMAKE := cmake
CONAN := conan

source_dir := ${CURDIR}
build_dir := ${source_dir}/.build

${build_dir} :
	mkdir -p $@

toolchain := ${build_dir}/conan_toolchain.cmake

${toolchain} : conanfile.txt | ${build_dir}
	${CMAKE} -E chdir ${build_dir} ${CONAN} install ${source_dir} --output-folder . --build=missing

conan : ${toolchain}

cache := ${build_dir}/CMakeCache.txt

cmake_args := \
	-DCMAKE_TOOLCHAIN_FILE=${toolchain} \
	-DCMAKE_BUILD_TYPE=Release \
	${source_dir}

${cache} : ${toolchain} CMakeLists.txt | ${build_dir}
	${CMAKE} -E chdir ${build_dir} ${CMAKE} ${cmake_args} 2>&1 | tee ${build_dir}/configure.log
	${CMAKE} -E touch $@

configure : ${cache}

clean :
	${CMAKE} -E rm -rf ${build_dir}
