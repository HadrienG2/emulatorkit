-- Copyright 2015 Hadrien Grasland
--
-- This file is part of EmulatorKit.
--
-- EmulatorKit is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- EmulatorKit is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with EmulatorKit.  If not, see <http://www.gnu.org/licenses/>.

-- This package enumerates the x86_64 registers, in a type hierarchy that highlights their relationships
package Emulator_Kit.CPU.Registers is

   -- First, let's list all the registers, before declaring more specific subtypes below.
   -- The order of enumeration matters. It roughly follows the chronological order of introduction.
   type Reg_8 is (AH, BH, CH, DH,
                  AL, BL, CL, DL,
                  SIL, DIL,
                  BPL, SPL,
                  R8B, R9B, R10B, R11B, R12B, R13B, R14B, R15B);

   type Reg_16 is (AX, BX, CX, DX,
                   DI, SI,
                   BP, SP,
                   R8W, R9W, R10W, R11W, R12W, R13W, R14W, R15W,
                   FLAGS,
                   IP);

   type Reg_32 is (EAX, EBX, ECX, EDX,
                   EDI, ESI,
                   EBP, ESP,
                   R8D, R9D, R10D, R11D, R12D, R13D, R14D, R15D,
                   EFLAGS,
                   EIP);

   type Reg_64 is (MMX0, MMX1, MMX2, MMX3, MMX4, MMX5, MMX6, MMX7,
                   RAX, RBX, RCX, RDX,
                   RBP, RSI,
                   RDI, RSP,
                   R8, R9, R10, R11, R12, R13, R14, R15,
                   RFLAGS,
                   RIP);

   type Reg_80 is (FPR0, FPR1, FPR2, FPR3, FPR4, FPR5, FPR6, FPR7);

   type Reg_128 is (XMM0, XMM1, XMM2, XMM3, XMM4, XMM5, XMM6, XMM7,
                    XMM8, XMM9, XMM10, XMM11, XMM12, XMM13, XMM14, XMM15);

   type Reg_256 is (YMM0, YMM1, YMM2, YMM3, YMM4, YMM5, YMM6, YMM7,
                    YMM8, YMM9, YMM10, YMM11, YMM12, YMM13, YMM14, YMM15);

   -- The general purpose registers (GP_Reg) may be accessed in many different ways
   subtype GP_Reg_8 is Reg_8 range AH .. R15B;
   subtype GP_Reg_High8 is GP_Reg_8 range AH .. DH; -- Cannot be used with the REX instruction prefix
   subtype GP_Reg_Low8 is GP_Reg_8 range AL .. R15B;
   subtype Legacy_GP_Reg_8 is GP_Reg_8 range AH .. DL;

   subtype GP_Reg_16 is Reg_16 range AX .. R15W;
   subtype Legacy_GP_Reg_16 is GP_Reg_16 range AX .. SP;

   subtype GP_Reg_32 is Reg_32 range EAX .. R15D;
   subtype Legacy_GP_Reg_32 is GP_Reg_32 range EAX .. ESP;

   subtype GP_Reg_64 is Reg_64 range RAX .. R15;

   -- The 80-bit x87 floating point registers are reused by the legacy 64-bit MMX and 3DNow! SIMD instructions
   subtype X87_Reg is Reg_80 range FPR0 .. FPR7;
   subtype MMX_Reg is Reg_64 range MMX0 .. MMX7;

   -- And the dedicated SIMD registers introduced by SSE and AVX instructions may also be accessed in multiple ways
   subtype XMM_Reg is Reg_128 range XMM0 .. XMM15;
   subtype Legacy_XMM_Reg is XMM_Reg range XMM0 .. XMM7;

   subtype YMM_Reg is Reg_256 range YMM0 .. YMM15;
   subtype Legacy_YMM_Reg is YMM_Reg range YMM0 .. YMM7;

end Emulator_Kit.CPU.Registers;
