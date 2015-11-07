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
with Emulator_Kit.Memory.Byte_Buffers;
with Emulator_Kit.Tasking.Processes;

-- There are many things that may act as memory in an x86 emulator : a simple buffer of bytes, the emulator host's memory,
-- a full memory bus emulation accounting for memory-mapped peripherals, some paging or segmentation-based virtual address space...
-- This package defines a common abstract interface to all these memory objects.
package Emulator_Kit.Memory.Abstract_Memory is

   -- First, let's define few shortcuts to make code more readable
   subtype Byte_Buffer_Handle is Memory.Byte_Buffers.Byte_Buffer_Handle;
   subtype Byte_Buffer_Size is Memory.Byte_Buffers.Byte_Buffer_Size;
   subtype Process_Handle is Tasking.Processes.Process_Handle;

   -- We propose that memory objects be implemented as tasks, as this allows for asynchronous data transfers.
   type Memory_Interface is task interface;

   -- It should be possible to probe the size of any implementation, as this helps for unit testing on the interface
   procedure Get_Size (Object : Memory_Interface; Size_In_Bytes : out Universal_Size) is abstract;

   -- The simplest memory interface that we can propose is a way to synchronously write standard x86_64 data types from variables...
   procedure Write (Target : in out Memory_Interface; Input : Data_Types.Byte; Output_Location : Universal_Address) is abstract;
   procedure Write (Target : in out Memory_Interface; Input : Data_Types.Word; Output_Location : Universal_Address) is abstract;
   procedure Write (Target : in out Memory_Interface; Input : Data_Types.Double_Word; Output_Location : Universal_Address) is abstract;
   procedure Write (Target : in out Memory_Interface; Input : Data_Types.Quad_Word; Output_Location : Universal_Address) is abstract;
   procedure Write (Target : in out Memory_Interface; Input : Data_Types.Two_Quad_Words; Output_Location : Universal_Address) is abstract;
   procedure Write (Target : in out Memory_Interface; Input : Data_Types.Four_Quad_Words; Output_Location : Universal_Address) is abstract;
   procedure Write (Target : in out Memory_Interface; Input : Data_Types.Float_Single; Output_Location : Universal_Address) is abstract;
   procedure Write (Target : in out Memory_Interface; Input : Data_Types.Float_Double; Output_Location : Universal_Address) is abstract;
   procedure Write (Target : in out Memory_Interface; Input : Data_Types.Float_Extended; Output_Location : Universal_Address) is abstract;

   -- ...and read them to variables
   procedure Read (Source : Memory_Interface; Input_Location : Universal_Address; Output : out Data_Types.Byte) is abstract;
   procedure Read (Source : Memory_Interface; Input_Location : Universal_Address; Output : out Data_Types.Word) is abstract;
   procedure Read (Source : Memory_Interface; Input_Location : Universal_Address; Output : out Data_Types.Double_Word) is abstract;
   procedure Read (Source : Memory_Interface; Input_Location : Universal_Address; Output : out Data_Types.Quad_Word) is abstract;
   procedure Read (Source : Memory_Interface; Input_Location : Universal_Address; Output : out Data_Types.Two_Quad_Words) is abstract;
   procedure Read (Source : Memory_Interface; Input_Location : Universal_Address; Output : out Data_Types.Four_Quad_Words) is abstract;
   procedure Read (Source : Memory_Interface; Input_Location : Universal_Address; Output : out Data_Types.Float_Single) is abstract;
   procedure Read (Source : Memory_Interface; Input_Location : Universal_Address; Output : out Data_Types.Float_Double) is abstract;
   procedure Read (Source : Memory_Interface; Input_Location : Universal_Address; Output : out Data_Types.Float_Extended) is abstract;

   -- The interface above is necessary for clean CPU emulation, but not efficient at all, and hence to be avoided for large data transfers.
   -- For these use cases, it is better to use the asynchronous bulk data transfers primitives that are provided below.

   -- The simplest and fastest bulk data transfer mode that may be envisioned is a bulk byte copy
   procedure Start_Copy (Within : in out Memory_Interface;
                         Input_Location : Universal_Address;
                         Output_Location : Universal_Address;
                         Byte_Count : Universal_Size;
                         Process : out Process_Handle) is abstract;
   procedure Start_Copy (Source : Memory_Interface;
                         Input_Location : Universal_Address;
                         Output : Byte_Buffer_Handle;
                         Byte_Count : Universal_Size;
                         Process : out Process_Handle) is abstract;
   procedure Start_Copy (Target : in out Memory_Interface;
                         Input : Byte_Buffer_Handle;
                         Output_Location : Universal_Address;
                         Byte_Count : Universal_Size;
                         Process : out Process_Handle) is abstract;

   -- An instance which validates all of these properties should pass the following set of unit tests, assuming that...
   --    * The test runner has been properly set up for the instance's host package
   --    * The instance's Get_Size method is correct (interface tests cannot check it !)
   --    * The instance has enough memory (current minimum : 128 bytes, recommended : 256 bytes)
   --    * It is safe to write everywhere within the instance's adress space (e.g. instance does not map to the full host memory)
   procedure Test_Instance (Instance : in out Memory_Interface'Class);

end Emulator_Kit.Memory.Abstract_Memory;
