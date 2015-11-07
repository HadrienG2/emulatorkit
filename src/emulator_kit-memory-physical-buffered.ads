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
with Emulator_Kit.Memory.Abstract_Memory;
with Emulator_Kit.Memory.Byte_Buffers;
with Emulator_Kit.Memory.Byte_Streams;
with Emulator_Kit.Tasking.Processes;

-- This package defines a physical memory implementation that is based on a buffer, isolated from host memory.
package Emulator_Kit.Memory.Physical.Buffered is

   -- First, let's define few shortcuts to make code more readable
   subtype Byte_Buffer_Handle is Memory.Byte_Buffers.Byte_Buffer_Handle;
   subtype Byte_Buffer_Size is Memory.Byte_Buffers.Byte_Buffer_Size;
   subtype Byte_Stream_Handle is Memory.Byte_Streams.Byte_Stream_Handle;
   subtype Process_Handle is Tasking.Processes.Process_Handle;

   -- Then comes the buffer-based physical memory implementation
   task type Buffer_Memory (Buffer_Size : Byte_Buffer_Size) is new Abstract_Memory.Memory_Interface with

      -- Size query
      overriding entry Get_Size (Size_In_Bytes : out Universal_Size);

      -- Element-wise primitive data write
      overriding entry Write (Input : Data_Types.Byte; Output_Location : Universal_Address);
      overriding entry Write (Input : Data_Types.Word; Output_Location : Universal_Address);
      overriding entry Write (Input : Data_Types.Double_Word; Output_Location : Universal_Address);
      overriding entry Write (Input : Data_Types.Quad_Word; Output_Location : Universal_Address);
      overriding entry Write (Input : Data_Types.Two_Quad_Words; Output_Location : Universal_Address);
      overriding entry Write (Input : Data_Types.Four_Quad_Words; Output_Location : Universal_Address);
      overriding entry Write (Input : Data_Types.Float_Single; Output_Location : Universal_Address);
      overriding entry Write (Input : Data_Types.Float_Double; Output_Location : Universal_Address);
      overriding entry Write (Input : Data_Types.Float_Extended; Output_Location : Universal_Address);

      -- Element-wise primitive data read
      overriding entry Read (Input_Location : Universal_Address; Output : out Data_Types.Byte);
      overriding entry Read (Input_Location : Universal_Address; Output : out Data_Types.Word);
      overriding entry Read (Input_Location : Universal_Address; Output : out Data_Types.Double_Word);
      overriding entry Read (Input_Location : Universal_Address; Output : out Data_Types.Quad_Word);
      overriding entry Read (Input_Location : Universal_Address; Output : out Data_Types.Two_Quad_Words);
      overriding entry Read (Input_Location : Universal_Address; Output : out Data_Types.Four_Quad_Words);
      overriding entry Read (Input_Location : Universal_Address; Output : out Data_Types.Float_Single);
      overriding entry Read (Input_Location : Universal_Address; Output : out Data_Types.Float_Double);
      overriding entry Read (Input_Location : Universal_Address; Output : out Data_Types.Float_Extended);

      -- Asynchronous copies within memory and to/from buffers
      overriding entry Start_Copy (Input_Location : Universal_Address;
                                   Output_Location : Universal_Address;
                                   Byte_Count : Universal_Size;
                                   Process : out Process_Handle);
      overriding entry Start_Copy (Input_Location : Universal_Address;
                                   Output : Byte_Buffer_Handle;
                                   Byte_Count : Universal_Size;
                                   Process : out Process_Handle);
      overriding entry Start_Copy (Input : Byte_Buffer_Handle;
                                   Output_Location : Universal_Address;
                                   Byte_Count : Universal_Size;
                                   Process : out Process_Handle);

   end Buffer_Memory;

end Emulator_Kit.Memory.Physical.Buffered;
