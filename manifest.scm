;;; irods_guix/manifest.scm --- Bit-to-bit reproducible iRODS envs
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
(specifications->manifest
 (list
  "irods@4.3.1"
  "irods-client-icommands@4.3.1"
  ))
