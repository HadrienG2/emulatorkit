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

with Emulator_Kit.Debug;
with Emulator_Kit.Debug.Test; pragma Elaborate_All (Emulator_Kit.Debug.Test);

package body Emulator_Kit.Memory.Physical.Buffered is

   use type Byte_Buffers.Byte_Buffer_Index;

   task body Buffer_Memory is

      -- Here are a couple more semantic shortcuts for the task's body
      subtype Byte_Buffer is Byte_Buffers.Byte_Buffer;
      subtype Byte_Buffer_Index is Byte_Buffers.Byte_Buffer_Index;

      -- First, let's define the memory buffer used to store memory, and its last valid address
      -- The internal buffer should be dynamically allocated, as it can get quite large depending on the emulated host.
      Internal_Buffer : constant access Byte_Buffer := new Byte_Buffer (0 .. Buffer_Size - 1);
      Last_Valid_Address : constant Universal_Address := Universal_Address (Internal_Buffer'Last);

      -- Convert memory addresses and object sizes to buffer indices and sizes
      function Address_To_Index (Location : Universal_Address) return Byte_Buffer_Index is (Byte_Buffer_Index (Location));
      function To_Bytes (Size_In_Bits : Positive) return Universal_Size is
        (Universal_Size (Size_In_Bits / 8 + (if Size_In_Bits mod 8 = 0 then 0 else 1)));

      -- Check that a memory access request is valid, if so return the associated internal buffer index
      function Checked_Index (Location : Universal_Address; Size : Universal_Size) return Byte_Buffer_Index is
      begin
         if Location > Last_Valid_Address or else Universal_Address'Pred (Location + Size) > Last_Valid_Address then
            raise Illegal_Address;
         else
            return Address_To_Index (Location);
         end if;
      end Checked_Index;

      -- This task performs asynchronous memory copies within the internal buffer
      task type Copy_Internal (Source_Index, Dest_Index : Byte_Buffer_Index; Byte_Count : Byte_Buffer_Size) is
         entry Start (Process : Process_Handle);
      end Copy_Internal;

      task body Copy_Internal is
         Copy_Process : Process_Handle;
      begin
         accept Start (Process : Process_Handle) do
            Copy_Process := Process;
         end Start;
         Internal_Buffer (Dest_Index .. Dest_Index + Byte_Count - 1) := Internal_Buffer (Source_Index .. Source_Index + Byte_Count - 1);
         Copy_Process.Target.Notify_Completion;
      exception
         when Occurrence : others =>
            Debug.Task_Message_Unhandled_Exception (Occurrence);
            Copy_Process.Target.Notify_Exception (Occurrence);
            raise;
      end Copy_Internal;

      type Copy_Internal_Access is access Copy_Internal;

      -- This task performs asynchronous memory copies to a user-specified byte buffer
      task type Copy_To_Buffer (Source_Index : Byte_Buffer_Index; Byte_Count : Byte_Buffer_Size) is
         entry Start (Destination : Byte_Buffer_Handle; Process : Process_Handle);
      end Copy_To_Buffer;

      task body Copy_To_Buffer is
         Copy_Process : Process_Handle;
         Dest_Buffer_Handle : Byte_Buffer_Handle;
         First_Dest_Index : Byte_Buffer_Index;
      begin
         accept Start (Destination : Byte_Buffer_Handle; Process : Process_Handle) do
            Dest_Buffer_Handle := Destination;
            Copy_Process := Process;
         end Start;
         First_Dest_Index := Dest_Buffer_Handle.Target'First;
         Dest_Buffer_Handle.Target (First_Dest_Index .. First_Dest_Index + Byte_Count - 1) :=
           Internal_Buffer (Source_Index .. Source_Index + Byte_Count - 1);
         Copy_Process.Target.Notify_Completion;
      exception
         when Occurrence : others =>
            Debug.Task_Message_Unhandled_Exception (Occurrence);
            Copy_Process.Target.Notify_Exception (Occurrence);
            raise;
      end Copy_To_Buffer;

      type Copy_To_Buffer_Access is access Copy_To_Buffer;

      -- This task performs asynchronous memory copies from a user-specified byte buffer
      task type Copy_From_Buffer (Dest_Index : Byte_Buffer_Index; Byte_Count : Byte_Buffer_Size) is
         entry Start (Source : Byte_Buffer_Handle; Process : Process_Handle);
      end Copy_From_Buffer;

      task body Copy_From_Buffer is
         Copy_Process : Process_Handle;
         Source_Buffer_Handle : Byte_Buffer_Handle;
         First_Source_Index : Byte_Buffer_Index;
      begin
         accept Start (Source : Byte_Buffer_Handle; Process : Process_Handle) do
            Source_Buffer_Handle := Source;
            Copy_Process := Process;
         end Start;
         First_Source_Index := Source_Buffer_Handle.Target'First;
         Internal_Buffer (Dest_Index .. Dest_Index + Byte_Count - 1) :=
           Source_Buffer_Handle.Target (First_Source_Index .. First_Source_Index + Byte_Count - 1);
         Copy_Process.Target.Notify_Completion;
      exception
         when Occurrence : others =>
            Debug.Task_Message_Unhandled_Exception (Occurrence);
            Copy_Process.Target.Notify_Exception (Occurrence);
            raise;
      end Copy_From_Buffer;

      type Copy_From_Buffer_Access is access Copy_From_Buffer;

   begin

      loop
         begin

            select
               -- Size query
               accept Get_Size (Size_In_Bytes : out Universal_Size) do
                  Size_In_Bytes := Universal_Size (Buffer_Size);
               end Get_Size;
            or
               -- Synchronous write instructions...
               accept Write (Input : Data_Types.Byte; Output_Location : Universal_Address) do
                  declare
                     Output_Index : constant Byte_Buffer_Index := Checked_Index (Output_Location, To_Bytes (Input'Size));
                  begin
                     Internal_Buffer (Output_Index) := Input;
                  end;
               end Write;
            or
               accept Write (Input : Data_Types.Word; Output_Location : Universal_Address) do
                  declare
                     Output_Index : constant Byte_Buffer_Index := Checked_Index (Output_Location, To_Bytes (Input'Size));
                  begin
                     Byte_Buffers.Unchecked_Write (Internal_Buffer.all, Output_Index, Input);
                  end;
               end Write;
            or
               accept Write (Input : Data_Types.Double_Word; Output_Location : Universal_Address) do
                  declare
                     Output_Index : constant Byte_Buffer_Index := Checked_Index (Output_Location, To_Bytes (Input'Size));
                  begin
                     Byte_Buffers.Unchecked_Write (Internal_Buffer.all, Output_Index, Input);
                  end;
               end Write;
            or
               accept Write (Input : Data_Types.Quad_Word; Output_Location : Universal_Address) do
                  declare
                     Output_Index : constant Byte_Buffer_Index := Checked_Index (Output_Location, To_Bytes (Input'Size));
                  begin
                     Byte_Buffers.Unchecked_Write (Internal_Buffer.all, Output_Index, Input);
                  end;
               end Write;
            or
               accept Write (Input : Data_Types.Two_Quad_Words; Output_Location : Universal_Address) do
                  declare
                     Output_Index : constant Byte_Buffer_Index := Checked_Index (Output_Location, To_Bytes (Input'Size));
                  begin
                     Byte_Buffers.Unchecked_Write (Internal_Buffer.all, Output_Index, Input);
                  end;
               end Write;
            or
               accept Write (Input : Data_Types.Four_Quad_Words; Output_Location : Universal_Address) do
                  declare
                     Output_Index : constant Byte_Buffer_Index := Checked_Index (Output_Location, To_Bytes (Input'Size));
                  begin
                     Byte_Buffers.Unchecked_Write (Internal_Buffer.all, Output_Index, Input);
                  end;
               end Write;
            or
               accept Write (Input : Data_Types.Float_Single; Output_Location : Universal_Address) do
                  declare
                     Output_Index : constant Byte_Buffer_Index := Checked_Index (Output_Location, To_Bytes (Input'Size));
                  begin
                     Byte_Buffers.Unchecked_Write (Internal_Buffer.all, Output_Index, Input);
                  end;
               end Write;
            or
               accept Write (Input : Data_Types.Float_Double; Output_Location : Universal_Address) do
                  declare
                     Output_Index : constant Byte_Buffer_Index := Checked_Index (Output_Location, To_Bytes (Input'Size));
                  begin
                     Byte_Buffers.Unchecked_Write (Internal_Buffer.all, Output_Index, Input);
                  end;
               end Write;
            or
               accept Write (Input : Data_Types.Float_Extended; Output_Location : Universal_Address) do
                  declare
                     Aliased_Input : aliased constant Data_Types.Float_Extended := Input;
                     Output_Index : constant Byte_Buffer_Index := Checked_Index (Output_Location, To_Bytes (Input'Size));
                  begin
                     Byte_Buffers.Unchecked_Write (Internal_Buffer.all, Output_Index, Aliased_Input);
                  end;
               end Write;

               -- ...synchronous read instructions...
            or
               accept Read (Input_Location : Universal_Address; Output : out Data_Types.Byte) do
                  declare
                     Input_Index : constant Byte_Buffer_Index := Checked_Index (Input_Location, To_Bytes (Output'Size));
                  begin
                     Output := Internal_Buffer (Input_Index);
                  end;
               end Read;
            or
               accept Read (Input_Location : Universal_Address; Output : out Data_Types.Word) do
                  declare
                     Input_Index : constant Byte_Buffer_Index := Checked_Index (Input_Location, To_Bytes (Output'Size));
                  begin
                     Byte_Buffers.Unchecked_Read (Internal_Buffer.all, Input_Index, Output);
                  end;
               end Read;
            or
               accept Read (Input_Location : Universal_Address; Output : out Data_Types.Double_Word) do
                  declare
                     Input_Index : constant Byte_Buffer_Index := Checked_Index (Input_Location, To_Bytes (Output'Size));
                  begin
                     Byte_Buffers.Unchecked_Read (Internal_Buffer.all, Input_Index, Output);
                  end;
               end Read;
            or
               accept Read (Input_Location : Universal_Address; Output : out Data_Types.Quad_Word) do
                  declare
                     Input_Index : constant Byte_Buffer_Index := Checked_Index (Input_Location, To_Bytes (Output'Size));
                  begin
                     Byte_Buffers.Unchecked_Read (Internal_Buffer.all, Input_Index, Output);
                  end;
               end Read;
            or
               accept Read (Input_Location : Universal_Address; Output : out Data_Types.Two_Quad_Words) do
                  declare
                     Input_Index : constant Byte_Buffer_Index := Checked_Index (Input_Location, To_Bytes (Output'Size));
                  begin
                     Byte_Buffers.Unchecked_Read (Internal_Buffer.all, Input_Index, Output);
                  end;
               end Read;
            or
               accept Read (Input_Location : Universal_Address; Output : out Data_Types.Four_Quad_Words) do
                  declare
                     Input_Index : constant Byte_Buffer_Index := Checked_Index (Input_Location, To_Bytes (Output'Size));
                  begin
                     Byte_Buffers.Unchecked_Read (Internal_Buffer.all, Input_Index, Output);
                  end;
               end Read;
            or
               accept Read (Input_Location : Universal_Address; Output : out Data_Types.Float_Single) do
                  declare
                     Input_Index : constant Byte_Buffer_Index := Checked_Index (Input_Location, To_Bytes (Output'Size));
                  begin
                     Byte_Buffers.Unchecked_Read (Internal_Buffer.all, Input_Index, Output);
                  end;
               end Read;
            or
               accept Read (Input_Location : Universal_Address; Output : out Data_Types.Float_Double) do
                  declare
                     Input_Index : constant Byte_Buffer_Index := Checked_Index (Input_Location, To_Bytes (Output'Size));
                  begin
                     Byte_Buffers.Unchecked_Read (Internal_Buffer.all, Input_Index, Output);
                  end;
               end Read;
            or
               accept Read (Input_Location : Universal_Address; Output : out Data_Types.Float_Extended) do
                  declare
                     Aliased_Output : aliased Data_Types.Float_Extended;
                     Input_Index : constant Byte_Buffer_Index := Checked_Index (Input_Location, To_Bytes (Output'Size));
                  begin
                     Byte_Buffers.Unchecked_Read (Internal_Buffer.all, Input_Index, Aliased_Output);
                     Output := Aliased_Output;
                  end;
               end Read;

               -- ...bulk copy instructions...
            or
               accept Start_Copy (Input_Location : Universal_Address;
                                  Output_Location : Universal_Address;
                                  Byte_Count : Universal_Size;
                                  Process : out Process_Handle) do
                  declare
                     Input_Index : constant Byte_Buffer_Index := Checked_Index (Input_Location, Byte_Count);
                     Output_Index : constant Byte_Buffer_Index := Checked_Index (Output_Location, Byte_Count);
                     Copy_Process : constant Process_Handle := Tasking.Processes.Make_Process;
                     Copy_Task_Access : constant Copy_Internal_Access := new Copy_Internal (Input_Index,
                                                                                            Output_Index,
                                                                                            Byte_Buffer_Size (Byte_Count));
                  begin
                     Copy_Task_Access.Start (Copy_Process);
                     Process := Copy_Process;
                  end;
               end Start_Copy;
            or
               accept Start_Copy (Input_Location : Universal_Address;
                                  Output : Byte_Buffer_Handle;
                                  Byte_Count : Universal_Size;
                                  Process : out Process_Handle) do
                  -- Check that the requested access does not go beyond buffer boundaries
                  if Byte_Count > Output.Target'Length then
                     raise Byte_Buffers.Buffer_Overflow;
                  end if;

                  -- Otherwise, proceed with the memory copy
                  declare
                     Input_Index : constant Byte_Buffer_Index := Checked_Index (Input_Location, Byte_Count);
                     Copy_Process : constant Process_Handle := Tasking.Processes.Make_Process;
                     Copy_Task_Access : constant Copy_To_Buffer_Access := new Copy_To_Buffer (Input_Index,
                                                                                              Byte_Buffer_Size (Byte_Count));
                  begin
                     Copy_Task_Access.Start (Output, Copy_Process);
                     Process := Copy_Process;
                  end;
               end Start_Copy;
            or
               accept Start_Copy (Input : Byte_Buffer_Handle;
                                  Output_Location : Universal_Address;
                                  Byte_Count : Universal_Size;
                                  Process : out Process_Handle) do
                  -- Check that the requested access does not go beyond buffer boundaries
                  if Byte_Count > Input.Target'Length then
                     raise Byte_Buffers.Buffer_Overflow;
                  end if;

                  -- Otherwise, proceed with the memory copy
                  declare
                     Output_Index : constant Byte_Buffer_Index := Checked_Index (Output_Location, Byte_Count);
                     Copy_Process : constant Process_Handle := Tasking.Processes.Make_Process;
                     Copy_Task_Access : constant Copy_From_Buffer_Access := new Copy_From_Buffer (Output_Index,
                                                                                                  Byte_Buffer_Size (Byte_Count));
                  begin
                     Copy_Task_Access.Start (Input, Copy_Process);
                     Process := Copy_Process;
                  end;
               end Start_Copy;

               -- ...and a terminate alternative to ensure task termination
            or
               terminate;
            end select;

         exception
             -- These exceptions are considered non-fatal, as they originate from silly client requests.
            when Illegal_Address | Byte_Buffers.Buffer_Overflow => null;
         end;
      end loop;

   exception
      -- Other exceptions are considered to be the memory task's fault
      when Occurrence : others =>
         Debug.Task_Message_Unhandled_Exception (Occurrence);
         raise;
   end Buffer_Memory;

   procedure Run_Tests is
      use Emulator_Kit.Debug.Test;

      procedure Test_Buffer_Memory is
         Buffer_Mem : Buffer_Memory (256);
         Advertised_Size : Universal_Size;
      begin
         Buffer_Mem.Get_Size (Advertised_Size);
         Test_Element_Property (Advertised_Size = Universal_Size (Buffer_Mem.Buffer_Size), "Buffer memory should advertise its actual size");
         Abstract_Memory.Test_Instance (Buffer_Mem);
      end Test_Buffer_Memory;

      procedure Test_Buffered_Package is
      begin
         Test_Package_Element (To_Entity_Name ("Buffer_Memory"), Test_Buffer_Memory'Access);
      end Test_Buffered_Package;
   begin
      Test_Package (To_Entity_Name ("Memory.Physical.Buffered"), Test_Buffered_Package'Access);
   end Run_Tests;

begin

   -- Automatically test the package when it is included
   Debug.Test.Elaboration_Self_Test (Run_Tests'Access);

end Emulator_Kit.Memory.Physical.Buffered;
