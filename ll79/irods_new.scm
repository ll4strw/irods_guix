;;; irods_guix/irods.scm --- Bit-to-bit reproducible iRODS envs
;;; Copyright © 2024 Leonardo Lenoci <l.lenoci@science.leidenuniv.nl>
;;;
;;; This file is part of irods_guix.
;;;
;;; irods_guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with irods_guix.  If not, see <http://www.gnu.org/licenses/>.
(define-module (irods)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages backup)
  #:use-module (gnu packages base)
  #:use-module (gnu packages boost)
  #:use-module (gnu packages check)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages cpp)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages kerberos)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages llvm)
  #:use-module (gnu packages logging)
  #:use-module (gnu packages man)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages pretty-print)
  #:use-module (gnu packages python)
  #:use-module (gnu packages serialization)
  #:use-module (gnu packages tls)
  #:use-module (srfi srfi-1))

(define-public irods
  (package
    (name "irods")
    (version "4.3.1")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/irods/irods/releases/download/"
                                  version "/irods-" version ".tar.gz"))
              (sha256
               (base32
                "1l373izk4v56zb86xn44ab25afbhs0q7h6vp6zkvwnz1xwd17h64"))))
    (build-system cmake-build-system)
    (arguments
     `(#:configure-flags
       (list
        "-DCMAKE_BUILD_TYPE=Release"
        (string-append "-DCMAKE_MODULE_LINKER_FLAGS=-Wl,-rpath="
                       (assoc-ref %outputs "out") "/lib")
        (string-append "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-rpath="
                       (assoc-ref %outputs "out") "/lib")
        (string-append "-DCMAKE_EXE_LINKER_FLAGS=-Wl,-rpath="
                       (assoc-ref %outputs "out") "/lib")

        ;; Configuration aborts if no generator format is set
        "-DCPACK_GENERATOR=TGZ"

        ;; Configuration attempts to guess the distribution with Python.
        "-DIRODS_LINUX_DISTRIBUTION_NAME=guix"
        "-DIRODS_LINUX_DISTRIBUTION_VERSION_MAJOR=1"

        (string-append "-DIRODS_EXTERNALS_FULLPATH_CLANG="
                       (assoc-ref %build-inputs "clang"))
        (string-append "-DIRODS_EXTERNALS_FULLPATH_CLANG_RUNTIME="
                       (assoc-ref %build-inputs "clang-runtime"))
        (string-append "-DIRODS_EXTERNALS_FULLPATH_CPPZMQ="
                       (assoc-ref %build-inputs "cppzmq"))
        (string-append "-DIRODS_EXTERNALS_FULLPATH_ARCHIVE="
                       (assoc-ref %build-inputs "libarchive"))
        (string-append "-DIRODS_EXTERNALS_FULLPATH_AVRO="
                       (assoc-ref %build-inputs "avro-cpp"))
        (string-append "-DIRODS_EXTERNALS_FULLPATH_BOOST="
                       (assoc-ref %build-inputs "boost"))
        (string-append "-DIRODS_EXTERNALS_FULLPATH_ZMQ="
                       (assoc-ref %build-inputs "zeromq"))
        (string-append "-DIRODS_EXTERNALS_FULLPATH_JSON="
                       (assoc-ref %build-inputs "json"))
        (string-append "-DIRODS_EXTERNALS_FULLPATH_CATCH2="
                       (assoc-ref %build-inputs "catch2"))
        (string-append "-DIRODS_EXTERNALS_FULLPATH_NANODBC="
                       (assoc-ref %build-inputs "nanodbc"))
	(string-append "-DIRODS_EXTERNALS_FULLPATH_SPDLOG="
                       (assoc-ref %build-inputs "spdlog"))
	(string-append "-DIRODS_BUILD_WITH_CLANG=ON")
	(string-append "-DIRODS_BUILD_AGAINST_LIBCXX=FALSE")
        (string-append "-DIRODS_EXTERNALS_FULLPATH_FMT="
                       (assoc-ref %build-inputs "fmt")))

       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'unset-Werror
           (lambda _
             ;; -Werror kills the build due to a comparison REQUIRE(errs.size() == err->len);
             ;; in unit_tests/src/test_irods_lifetime_manager.cpp
             (substitute* "CMakeLists.txt"
               (("-Werror") ""))))
         (add-after 'unpack 'remove-FHS-and-prefix-assumptions
           (lambda* (#:key inputs #:allow-other-keys)
             (substitute* "lib/core/src/irods_default_paths.cpp"
               (("path.append\\(\"usr\"\\)") "path")
               (("path.remove_filename\\(\\).remove_filename\\(\\).remove_filename\\(\\)")
                "path.remove_filename().remove_filename()"))
             (substitute* "scripts/irods/paths.py"
               (("'usr', 'lib', 'irods'") "'lib', 'irods'"))
	     ))
	 )))
    (inputs
     `(("avro-cpp" ,avro-cpp-1.11)
       ("boost" ,boost)
       ("cppzmq" ,cppzmq)
       ("fmt" ,fmt-8)
       ("json" ,nlohmann-json)
       ("libarchive" ,libarchive)
       ("linux-pam" ,linux-pam)
       ("mit-krb5" ,mit-krb5)
       ("nanodbc" ,nanodbc)
       ("openssl" ,openssl)
       ("python" ,python-wrapper)
       ("spdlog" ,spdlog)
       ("unixodbc" ,unixodbc)
       ("zeromq" ,zeromq)))
    (native-inputs
     `(("catch2" ,catch2)
       ("clang" ,clang-toolchain-13)
       ("clang-runtime" ,clang-runtime-13)
       ("curl" ,curl)
       ("nanodbc" ,nanodbc)
       ))
    (home-page "https://irods.org")
    (synopsis "Data management software")
    (description "The Integrated Rule-Oriented Data System (iRODS) is data
management software.  iRODS virtualizes data storage resources, so users can
take control of their data, regardless of where and on what device the data is
stored.")
    (license license:bsd-3)))

(define-public irods-client-icommands
  (package
    (name "irods-client-icommands")
    (version "4.3.1")
    (source (origin
	     (method url-fetch)
             (uri (string-append "https://github.com/irods/irods-client-icommands/archive/refs/tags/" version ".tar.gz"))
              (sha256
               (base32
                "0v1yyrq6hy661d1g03mqmr2w8acdli76nly4rwk3qqqavlr75l2c"))))
    (build-system cmake-build-system)
    (arguments
     `(#:tests? #false ; not clear how to run tests
       #:configure-flags
       (list
        "-DCMAKE_BUILD_TYPE=Release"

        ;; Configuration attempts to guess the distribution with Python.
        "-DIRODS_LINUX_DISTRIBUTION_NAME=guix"
        "-DIRODS_LINUX_DISTRIBUTION_VERSION_MAJOR=1"
;;;	"-DIRODS_LINUX_DISTRIBUTION_VERSION_CODENAME=guix"
	"-DCPACK_GENERATOR=TGZ"
	
        (string-append "-DIRODS_DIR="
                       (assoc-ref %build-inputs "irods")
                       "/lib/irods/cmake")
        (string-append "-DIRODS_EXTERNALS_FULLPATH_CLANG="
                       (assoc-ref %build-inputs "clang"))
        (string-append "-DIRODS_EXTERNALS_FULLPATH_CLANG_RUNTIME="
                       (assoc-ref %build-inputs "clang-runtime"))
        (string-append "-DIRODS_EXTERNALS_FULLPATH_CPPZMQ="
                       (assoc-ref %build-inputs "cppzmq"))
        (string-append "-DIRODS_EXTERNALS_FULLPATH_ARCHIVE="
                       (assoc-ref %build-inputs "libarchive"))
        (string-append "-DIRODS_EXTERNALS_FULLPATH_AVRO="
                       (assoc-ref %build-inputs "avro-cpp"))
        (string-append "-DIRODS_EXTERNALS_FULLPATH_BOOST="
                       (assoc-ref %build-inputs "boost"))
        (string-append "-DIRODS_EXTERNALS_FULLPATH_ZMQ="
                       (assoc-ref %build-inputs "zeromq"))
        (string-append "-DIRODS_EXTERNALS_FULLPATH_JSON="
                       (assoc-ref %build-inputs "json"))
        (string-append "-DIRODS_EXTERNALS_FULLPATH_FMT="
                       (assoc-ref %build-inputs "fmt"))
	(string-append "-DIRODS_BUILD_WITH_CLANG=ON")
	(string-append "-DIRODS_BUILD_AGAINST_LIBCXX=FALSE")
	)

       #:phases
       (modify-phases %standard-phases
		      (add-after 'unpack 'unset-Werror ;
				 (lambda _                           ;
				   ;; -Werror kills the build due to a deprecation warning
				   (substitute* "CMakeLists.txt" ;
						(("-Werror") ""))))
		      (add-after 'unpack 'remove-/usr-prefix
				 (lambda _
				   (substitute* "CMakeLists.txt"
						(("usr/") ""))))
		      )))
    (inputs
     `(("avro-cpp" ,avro-cpp-1.11)
       ("boost" ,boost)
       ("cppzmq" ,cppzmq)
       ("fmt" ,fmt-8)
       ("irods" ,irods)
       ("json" ,nlohmann-json)
       ("libarchive" ,libarchive)
       ("mit-krb5" ,mit-krb5)
       ("openssl" ,openssl)
       ("zeromq" ,zeromq)))
    (native-inputs
     `(("clang" ,clang-toolchain-13)
       ("clang-runtime" ,clang-runtime-13)
       ("help2man" ,help2man)
       ("which" ,which)))
    (home-page "https://irods.org")
    (synopsis "Data management software")
    (description "The Integrated Rule-Oriented Data System (iRODS) is data
management software.  iRODS virtualizes data storage resources, so users can
take control of their data, regardless of where and on what device the data is
stored.")
    (license license:bsd-3)))
