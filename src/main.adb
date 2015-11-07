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

with Ada.Text_IO;

-- We import every single unit into Main to ensure that it builds properly.
-- Compiler warnings about unused units should thus be suppressed.
pragma Warnings (Off);
with Emulator_Kit;
with Emulator_Kit.CPU;
with Emulator_Kit.CPU.Registers;
with Emulator_Kit.CPU.Registers.Data;
with Emulator_Kit.Data_Types;
with Emulator_Kit.Debug;
with Emulator_Kit.Debug.Test;
with Emulator_Kit.Memory;
with Emulator_Kit.Memory.Abstract_Memory;
with Emulator_Kit.Memory.Byte_Buffers;
with Emulator_Kit.Memory.Physical;
with Emulator_Kit.Memory.Physical.Buffered;
with Emulator_Kit.Tasking;
with Emulator_Kit.Tasking.Processes;
with Emulator_Kit.Tasking.Shared_Resources;
pragma Warnings (On);

procedure Main is
   use Ada;
   use Emulator_Kit;
   use type Memory.Universal_Address, Memory.Universal_Size;
   use type Memory.Byte_Buffers.Byte_Buffer_Index;

   subtype Byte_Buffer_Handle is Memory.Byte_Buffers.Byte_Buffer_Handle;
   subtype Byte_Buffer_Index is Memory.Byte_Buffers.Byte_Buffer_Index;
   subtype Process_Handle is Tasking.Processes.Process_Handle;

   Mem_Size : constant := 2 ** 31; -- Program requires twice that memory to run (once for emulated memory, once for client buffer)

   Emulated_Memory : Memory.Physical.Buffered.Buffer_Memory (Mem_Size);
   Buffer_Handle : constant Byte_Buffer_Handle := Memory.Byte_Buffers.Make_Byte_Buffer (Mem_Size);

   -- Set this mode to Buffer in order to test a memory copy
   type Mode is (Buffer, No_Op);
   Active_Mode : constant Mode := No_Op;

   function Gen_Byte (Index : Byte_Buffer_Index) return Data_Types.Byte is (Data_Types.Byte (Byte_Buffer_Index (Index - 1) * 256 / Mem_Size));
begin
   case Active_Mode is

      when Buffer =>
         Text_IO.Put_Line ("Filling a buffer with increasing bytes...");
         for Index in Byte_Buffer_Index range 1 .. Mem_Size loop
            Buffer_Handle.Target.all (Index) := Gen_Byte (Index);
         end loop;

         --     Text_IO.Put_Line ("Initial buffer contents :");
         --     for Byte of Buffer_Handle.Target.all loop
         --        Text_IO.Put_Line (Data_Types.Byte'Image (Byte));
         --     end loop;

         Text_IO.Put_Line ("Initializing memory with the buffer's contents...");
         declare
            Copy_Process_Handle : Process_Handle;
         begin
            Emulated_Memory.Start_Copy (Buffer_Handle, 0, Mem_Size, Copy_Process_Handle);
            Copy_Process_Handle.Target.Wait_For_Completion;
         end;

         Text_IO.Put_Line ("Performing an internal memory copy...");
         declare
            Copy_Process_Handle : Process_Handle;
         begin
            Emulated_Memory.Start_Copy (0, Mem_Size / 2, Mem_Size / 2, Copy_Process_Handle);
            Copy_Process_Handle.Target.Wait_For_Completion;
         end;

         Text_IO.Put_Line ("Moving the contents of memory to a client-side buffer...");
         declare
            Copy_Process_Handle : Process_Handle;
         begin
            Emulated_Memory.Start_Copy (0, Buffer_Handle, Mem_Size, Copy_Process_Handle);
            Copy_Process_Handle.Target.Wait_For_Completion;
         end;

         --     Text_IO.Put_Line ("Final buffer contents :");
         --     for Byte of Buffer_Handle.Target.all loop
         --        Text_IO.Put_Line (Data_Types.Byte'Image (Byte));
         --     end loop;

      when No_Op =>
         null;

   end case;
   Text_IO.Put_Line ("All done !");
end Main;
