
;  Copyright 2023, David S. Madole <david@madole.net>
;
;  This program is free software: you can redistribute it and/or modify
;  it under the terms of the GNU General Public License as published by
;  the Free Software Foundation, either version 3 of the License, or
;  (at your option) any later version.
;
;  This program is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;  GNU General Public License for more details.
;
;  You should have received a copy of the GNU General Public License
;  along with this program.  If not, see <https://www.gnu.org/licenses/>.


          ; Definition files

          #include include/bios.inc
          #include include/kernel.inc


          ; Executable header block

            org   1ffah
            dw    begin
            dw    end-begin
            dw    begin

begin:      br    start

            db    4+80h
            db    3
            dw    2024
            dw    1

            db    'See github/dmadole/Elfos-del for more information',0


start:      ldi   0                     ; clear option flags
            phi   r9

skipini:    lda   ra                    ; skip any leading spaces
            lbz   dousage
            sdi   ' '
            lbdf  skipini

            sdi   ' '-'-'               ; a dash starts an option
            lbnz  notdash

            lda   ra                    ; the v option is for verbose
            smi   'v'
            lbnz  notvopt

            ghi   r9                    ; set the flag for verbose
            ori   1
            phi   r9

            lbr   endopts

notvopt:    smi   'd'-'v'
            lbnz  dousage

            ghi   r9                    ; set the flag for directory
            ori   2
            phi   r9

            lbr   endopts


endopts:    lda   ra                    ; make sure a space follows
            lbz   dousage
            sdi   ' '
            lbdf  skipini

            lbr   dousage               ; if not then error


          ; If not an option, then it is the source path name.

notdash:    dec   ra                    ; back up to first char

            ghi   ra                    ; switch to rf
            phi   rf
            glo   ra
            plo   rf

            ldi   srcname.1             ; pointer to file name
            phi   ra
            ldi   srcname.0
            plo   ra
 
copysrc:    lda   rf                    ; done if end of name
            lbz   endargs

            str   ra                    ; else copy until end
            inc   ra
            sdi   ' '
            lbnf  copysrc

            dec   ra                    ; back to first space

skipend:    lda   rf
            lbz   endargs
            sdi   ' '
            lbdf  skipend

dousage:    sep   scall
            dw    o_inmsg
            db    'USAGE: del [-v] [-d] path',13,10,0

            sep   sret




          ; If the source path does not end in a slash then add one so that
          ; opendir tries to open the path as a directory. Leave RA pointing
          ; to the slash, not the terminator so we know that we added it.

endargs:    str   ra                    ; terminate path name

            dec   ra                    ; if already a slash do nothing
            lda   ra
            smi   '/'
            lbz   slashed

            ldi   '/'                   ; else add a slash
            str   ra
            inc   ra

            ldi   0                     ; terminate path name
            str   ra
            dec   ra

slashed:    ldi   source.1
            phi   rd
            ldi   source.0
            plo   rd

            ldi   srcname.1
            phi   rf
            ldi   srcname.0
            plo   rf

            ldi   16
            plo   r7

            sep   scall
            dw    opendir
            lbnf  destdir


            ldn   ra
            lbnz  unslash

            sep   scall
            dw    o_inmsg
            db    'ERROR: path is not directory',13,10,0

            sep   sret

unslash:    ldi   0
            str   ra

            sep   scall
            dw    delfile

            sep   sret





destdir:    glo   ra                    ; if just a slash, confirm
            smi   1+srcname.0
            lbz   confirm

            ldn   ra                    ; if user added slash, proceed
            lbz   nextent

confirm:    ghi   r9                    ; if -d option given, proceed
            ani   2
            lbnz  skpslsh

            sep   scall                 ; prompt user
            dw    o_inmsg
            db    'delete files in directory ',0

            ldi   0                     ; remove trailing slash
            str   ra

            ldi   srcname.1             ; get path to name
            phi   rf
            ldi   srcname.0
            plo   rf

            sep   scall                 ; output name
            dw    o_msg

            sep   scall                 ; make it a question
            dw    o_inmsg
            db    '? ',0

            ldi   buffer.1              ; buffer for answer
            phi   rf
            ldi   buffer.0
            plo   rf

            sep   scall                 ; get users input
            dw    o_input
             
            sep   scall                 ; move to new line
            dw    o_inmsg
            db    13,10,0

            ldi   buffer.1              ; pointer to input
            phi   rf
            ldi   buffer.0
            plo   rf

            ldn   rf                    ; if confirmed, proceed
            smi   'y'
            lbz   addslsh

            smi   'y'-'Y'               ; else abandon
            lbnz  return

addslsh:    ldi   '/'                   ; add slash back on
            str   ra
skpslsh:    inc   ra


nextent:    ldi   source.1
            phi   rd
            ldi   source.0
            plo   rd

            ldi   dirent.1
            phi   rf
            ldi   dirent.0
            plo   rf

            ldi   32.1
            phi   rc
            ldi   32.0
            plo   rc

            sep   scall
            dw    o_read
            lbdf  inpfail

            glo   rc
            smi   32
            lbnz  lastdir

            ldi   dirent.1
            phi   rf
            ldi   dirent.0
            plo   rf

            lda   rf
            lbnz  entused+0
            lda   rf
            lbnz  entused+1
            lda   rf
            lbnz  entused+2
            lda   rf
            lbnz  entused+3

            lbr   nextent

entused:    inc   rf
            inc   rf
            inc   rf
            inc   rf
            inc   rf

            ldn   rf
            ani   1
            lbnz  nextent

            ghi   ra
            phi   rf
            glo   ra
            plo   rf

            ldi   (dirent+12).1
            phi   rc
            ldi   (dirent+12).0
            plo   rc

filesrc:    lda   rc
            str   rf
            inc   rf
            lbnz  filesrc

            sep   scall
            dw    delfile

            lbr   nextent


delfile:    ghi   r9
            ani   1
            lbz   notverb

            ldi   srcname.1
            phi   rf
            ldi   srcname.0
            plo   rf
      
            sep   scall
            dw    o_msg

            sep   scall
            dw    o_inmsg
            db    13,10,0

notverb:    ldi   srcname.1
            phi   rf
            ldi   srcname.0
            plo   rf
      
            sep   scall
            dw    o_delete

return:     sep   sret


lastdir:    ldi   0
            dec   ra
            str   ra

            ldi   srcname.1
            phi   rf
            ldi   srcname.0
            plo   rf

            sep   scall
            dw    o_rmdir

            sep   sret




inpfail:    sep   scall
            dw    o_inmsg
            db    'failed',13,10,0

            sep   sret



          ; ------------------------------------------------------------------
          ; The o_open call can't open the root directory, but o_opendir can,
          ; however on Elf/OS 4 it returns a system filedescriptor that will
          ; be overwritten when opening the next file. So we call o_opendir
          ; but then create a copy of the file descriptor in that case.

opendir:    glo   rd                    ; save the passed descriptor
            stxd
            ghi   rd
            stxd

            glo   ra                    ; in elf/os 4 opendir trashes ra
            stxd
            ghi   ra
            stxd

            glo   r9                    ; and also r9
            stxd
            ghi   r9
            stxd

            sep   scall                 ; open the directory
            dw    o_opendir

            irx                         ; restore original r9
            ldxa
            phi   r9
            ldxa
            plo   r9

            ldxa                        ; and ra
            phi   ra
            ldxa
            plo   ra


          ; If opendir failed then no need to copy the descriptor, just 
          ; restore the original RD and return.

            lbnf  success               ; did opendir succeed?

            ldxa                        ; if not restore original rd
            phi   rd
            ldx
            plo   rd

            sep   sret                  ; and return


          ; If RD did not change, then opendir might have failed, or it may
          ; have succeeded on a later version of Elf/OS that uses the passed
          ; descriptor rather than a system descriptor. Either way, return.

success:    ghi   rd                    ; see if rd changed
            xor
            lbnz  changed

            irx                         ; if not, don't copy fildes
            sep   sret


          ; Otherwise, we opened the directory, but have been returned a 
          ; pointer to a system file descriptor. Copy it before returning.

changed:    ldxa                        ; get saved rd into r9
            phi   rf
            ldx
            plo   rf

            ldi   4                     ; first 4 bytes are offset
            plo   re

copyfd1:    lda   rd                    ; copy them 
            str   rf
            inc   rf

            dec   re                    ; until all 4 complete
            glo   re
            lbnz  copyfd1

            lda   rd                    ; next 2 are the dta pointer
            phi   r7
            lda   rd
            plo   r7

            lda   rf                    ; get for source and destination
            phi   r8
            lda   rf
            plo   r8

            ldi   13                    ; remaining byte count in fildes
            plo   re

copyfd2:    lda   rd                    ; copy remaining bytes
            str   rf
            inc   rf

            dec   re                    ; complete to total of 19 bytes
            glo   re
            lbnz  copyfd2

            ldi   255                   ; count to copy, mind the msb
            plo   re
            inc   re

copydta:    lda   r7                    ; copy two bytes at a time
            str   r8
            inc   r8
            lda   r7
            str   r8
            inc   r8

            dec   re                    ; continue until dta copied
            glo   re
            lbnz  copydta

            glo   rf                    ; set copy fildes back into rd
            smi   19
            plo   rd
            ghi   rf
            smbi  0
            phi   rd

            adi   0                     ; return with df cleared
            sep   sret




          ; File descriptor used for both intput and output files.

source:     db    0,0,0,0
            dw    dta
            db    0,0,0,0,0,0,0,0,0,0,0,0,0

dirent:     ds    32

srcname:    ds    256

buffer:     ds    256


          ; Data transfer area that is included in executable header size
          ; but not actually included in executable.

dta:        ds    512

end:        end    begin
