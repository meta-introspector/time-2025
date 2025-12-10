fn main() {
    // Point the linker to the library directory within the user's GNU Octave installation.
//    println!("cargo:rustc-link-search=native=C:/Program Files/GNU Octave/Octave-10.3.0/mingw64/lib");

    // Link against the OpenBLAS (which includes BLAS and LAPACK) and gfortran runtime
    // libraries provided by that environment.
//    println!("cargo:rustc-link-lib=dylib=openblas");
//    println!("cargo:rustc-link-lib=dylib=gfortran");
}
