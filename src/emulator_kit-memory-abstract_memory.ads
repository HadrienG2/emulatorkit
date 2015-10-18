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
with Emulator_Kit.Memory.Byte_Streams;
with Emulator_Kit.Tasking.Processes;

-- There are many things that may act as memory in an x86 emulator : a simple buffer of bytes, the emulator host's memory,
-- a full memory bus emulation accounting for memory-mapped peripherals, some paging or segmentation-based virtual address space...
-- This package defines a common abstract interface to all these memory objects.
package Emulator_Kit.Memory.Abstract_Memory is

   -- First, let's define few shortcuts to make code more readable
   subtype Byte_Buffer_Handle is Memory.Byte_Buffers.Byte_Buffer_Handle;
   subtype Byte_Buffer_Size is Memory.Byte_Buffers.Byte_Buffer_Size;
   subtype Byte_Stream_Handle is Memory.Byte_Streams.Byte_Stream_Handle;
   subtype Process_Handle is Tasking.Processes.Process_Handle;

   -- We propose that memory objects be implemented as tasks, as this allows for asynchronous data transfers.
   type Memory_Interface is task interface;

   -- The simplest memory interface that we can propose is a way to synchronously write standard x86_64 data types from variables...
   procedure Write (Memory : Memory_Interface; Input : Data_Types.Byte; Output_Location : Universal_Address) is abstract;
   procedure Write (Memory : Memory_Interface; Input : Data_Types.Word; Output_Location : Universal_Address) is abstract;
   procedure Write (Memory : Memory_Interface; Input : Data_Types.Double_Word; Output_Location : Universal_Address) is abstract;
   procedure Write (Memory : Memory_Interface; Input : Data_Types.Quad_Word; Output_Location : Universal_Address) is abstract;
   procedure Write (Memory : Memory_Interface; Input : Data_Types.Two_Quad_Words_Access_Const; Output_Location : Universal_Address) is abstract;
   procedure Write (Memory : Memory_Interface; Input : Data_Types.Four_Quad_Words_Access_Const; Output_Location : Universal_Address) is abstract;
   procedure Write (Memory : Memory_Interface; Input : Data_Types.Float_Single; Output_Location : Universal_Address) is abstract;
   procedure Write (Memory : Memory_Interface; Input : Data_Types.Float_Double; Output_Location : Universal_Address) is abstract;
   procedure Write (Memory : Memory_Interface; Input : Data_Types.Float_Extended_Access_Const; Output_Location : Universal_Address) is abstract;

   -- ...and read them to variables
   procedure Read (Memory : Memory_Interface; Input_Location : Universal_Address; Output : out Data_Types.Byte) is abstract;
   procedure Read (Memory : Memory_Interface; Input_Location : Universal_Address; Output : out Data_Types.Word) is abstract;
   procedure Read (Memory : Memory_Interface; Input_Location : Universal_Address; Output : out Data_Types.Double_Word) is abstract;
   procedure Read (Memory : Memory_Interface; Input_Location : Universal_Address; Output : out Data_Types.Quad_Word) is abstract;
   procedure Read (Memory : Memory_Interface; Input_Location : Universal_Address; Output : Data_Types.Two_Quad_Words_Access) is abstract;
   procedure Read (Memory : Memory_Interface; Input_Location : Universal_Address; Output : Data_Types.Four_Quad_Words_Access) is abstract;
   procedure Read (Memory : Memory_Interface; Input_Location : Universal_Address; Output : out Data_Types.Float_Single) is abstract;
   procedure Read (Memory : Memory_Interface; Input_Location : Universal_Address; Output : out Data_Types.Float_Double) is abstract;
   procedure Read (Memory : Memory_Interface; Input_Location : Universal_Address; Output : Data_Types.Float_Extended_Access) is abstract;

   -- The interface above is necessary for clean CPU emulation, but not efficient at all, and hence to be avoided for large data transfers.
   -- For these use cases, it is better to use the asynchronous bulk data transfers primitives that are provided below.

   -- The simplest and fastest bulk data transfer mode that may be envisioned is a bulk byte copy
   procedure Start_Copy (Memory : Memory_Interface;
                         Input_Location : Universal_Address;
                         Output_Location : Universal_Address;
                         Byte_Count : Universal_Size;
                         Process : out Process_Handle) is abstract;
   procedure Start_Copy (Memory : Memory_Interface;
                         Input_Location : Universal_Address;
                         Output : Byte_Buffer_Handle;
                         Byte_Count : Universal_Size;
                         Process : out Process_Handle) is abstract;
   procedure Start_Copy (Memory : Memory_Interface;
                         Input : Byte_Buffer_Handle;
                         Output_Location : Universal_Address;
                         Byte_Count : Universal_Size;
                         Process : out Process_Handle) is abstract;

   -- When the amount of requested data is unknown, or if the data must be processed before reads or writes as in instruction fetches,
   -- it can also be useful to continuously stream data from someplace.
   --
   -- A chunk size of 4096 provides a fairly good compromise between performance and memory size for large data transfers.
   procedure Start_Reading (Memory : Memory_Interface;
                            Input_Location : Universal_Address;
                            Stream_Chunk_Size : Byte_Buffer_Size;
                            Stream : out Byte_Stream_Handle) is abstract;
   procedure Start_Writing (Memory : Memory_Interface;
                            Output_Location : Universal_Address;
                            Stream_Chunk_Size : Byte_Buffer_Size;
                            Stream : out Byte_Stream_Handle) is abstract;

end Emulator_Kit.Memory.Abstract_Memory;
