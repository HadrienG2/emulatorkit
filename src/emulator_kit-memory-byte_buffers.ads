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

with Emulator_Kit.Data_Types;
with Emulator_Kit.Memory.Physical;
with Emulator_Kit.Tasking.Shared_Resources;

-- This package defines buffers of bytes, intended as a temporary memory storage location
package Emulator_Kit.Memory.Byte_Buffers is

   -- This exception will be thrown if a client requests the emulator to access a byte buffer beyond its bounds
   Overflow : exception;

   -- Buffers may be as large as the AMD64 upper physical memory size limit.
   -- They also must be aliased, to allow for raw access from assembly code.
   -- They may be indexed either on a 0- or 1-based basis.
   type Byte_Buffer_Index is range 0 .. Physical.Max_Memory_Size;
   type Byte_Buffer is array (Byte_Buffer_Index range <>) of aliased Data_Types.Byte;
   subtype Byte_Buffer_Size is Byte_Buffer_Index; -- Must be a subtype to allow for discriminated types

   -- In Ada, efficiently loading and storing data to and from an array of bytes takes a bit of assembly.
   -- Here, we provide a couple of functions that will do the trick for all the primitive types.
   -- These functions do not perform bounds checking, as that is best implemented on the client side.
   procedure Unchecked_Write (Buffer : in out Byte_Buffer; Location : Byte_Buffer_Index; Input : Data_Types.Word) with Inline;
   procedure Unchecked_Write (Buffer : in out Byte_Buffer; Location : Byte_Buffer_Index; Input : Data_Types.Double_Word) with Inline;
   procedure Unchecked_Write (Buffer : in out Byte_Buffer; Location : Byte_Buffer_Index; Input : Data_Types.Quad_Word) with Inline;
   procedure Unchecked_Write (Buffer : in out Byte_Buffer; Location : Byte_Buffer_Index; Input : Data_Types.Two_Quad_Words_Access_Const) with Inline;
   procedure Unchecked_Write (Buffer : in out Byte_Buffer; Location : Byte_Buffer_Index; Input : Data_Types.Four_Quad_Words_Access_Const) with Inline;
   procedure Unchecked_Write (Buffer : in out Byte_Buffer; Location : Byte_Buffer_Index; Input : Data_Types.Float_Single) with Inline;
   procedure Unchecked_Write (Buffer : in out Byte_Buffer; Location : Byte_Buffer_Index; Input : Data_Types.Float_Double) with Inline;
   procedure Unchecked_Write (Buffer : in out Byte_Buffer; Location : Byte_Buffer_Index; Input : Data_Types.Float_Extended_Access_Const) with Inline;

   procedure Unchecked_Read (Buffer : Byte_Buffer; Location : Byte_Buffer_Index; Output : out Data_Types.Word) with Inline;
   procedure Unchecked_Read (Buffer : Byte_Buffer; Location : Byte_Buffer_Index; Output : out Data_Types.Double_Word) with Inline;
   procedure Unchecked_Read (Buffer : Byte_Buffer; Location : Byte_Buffer_Index; Output : out Data_Types.Quad_Word) with Inline;
   procedure Unchecked_Read (Buffer : Byte_Buffer; Location : Byte_Buffer_Index; Output : Data_Types.Two_Quad_Words_Access) with Inline;
   procedure Unchecked_Read (Buffer : Byte_Buffer; Location : Byte_Buffer_Index; Output : Data_Types.Four_Quad_Words_Access) with Inline;
   procedure Unchecked_Read (Buffer : Byte_Buffer; Location : Byte_Buffer_Index; Output : out Data_Types.Float_Single) with Inline;
   procedure Unchecked_Read (Buffer : Byte_Buffer; Location : Byte_Buffer_Index; Output : out Data_Types.Float_Double) with Inline;
   procedure Unchecked_Read (Buffer : Byte_Buffer; Location : Byte_Buffer_Index; Output : Data_Types.Float_Extended_Access) with Inline;

   -- Byte buffers are likely to be shared between tasks, so we implement the shared handle mechanism for them
   package Shared_Byte_Buffers is new Tasking.Shared_Resources (Resource => Byte_Buffer);
   subtype Byte_Buffer_Access is Shared_Byte_Buffers.Resource_Access;
   subtype Byte_Buffer_Handle is Shared_Byte_Buffers.Resource_Handle;
   function Is_Valid (Handle : Byte_Buffer_Handle) return Boolean renames Shared_Byte_Buffers.Is_Valid;
   function Target (Handle : Byte_Buffer_Handle) return not null Byte_Buffer_Access renames Shared_Byte_Buffers.Target;
   function Make_Byte_Buffer (Max_Index : Byte_Buffer_Index; Min_Index : Byte_Buffer_Index := 1) return Byte_Buffer_Handle is
     (Shared_Byte_Buffers.Make_Shared (new Byte_Buffer (Min_Index .. Max_Index)));

end Emulator_Kit.Memory.Byte_Buffers;
