with Emulator_Kit.Debug.Test;

package body Emulator_Kit.Memory.Abstract_Memory is

   procedure Test_Instance (Instance : in out Memory_Interface'Class) is
      use Emulator_Kit.Debug.Test;
      use type Universal_Size;
      Instance_Size : Universal_Size;
   begin
      -- Check instance size requirements
      Instance.Get_Size (Instance_Size);
      Test_Element_Property (Instance_Size >= 128, "Tested memory interface instance should have at least 128 bytes of storage");

      -- Test byte I/O
      declare
         subtype Byte_Buffer is Byte_Buffers.Byte_Buffer;
         use type Byte_Buffer;
         Output : Byte_Buffer (1 .. 2);
      begin
         -- At the beginning of memory
         declare
            Input : constant Byte_Buffer (1 .. 2) := (42, 24);
         begin
            Instance.Write (Input (1), 0);
            Instance.Write (Input (2), 1);
            Instance.Read (0, Output (1));
            Instance.Read (1, Output (2));
            Test_Element_Property (Input = Output, "Writing bytes at the beginning of memory should work");
         end;

         -- At the end of memory (including out of bounds)
         declare
            Input : constant Byte_Buffer (1 .. 2) := (64, 46);
         begin
            Instance.Write (Input (1), Universal_Address (Instance_Size - 1));
            Instance.Write (Input (2), Universal_Address (Instance_Size - 2));
            Instance.Read (Universal_Address (Instance_Size - 1), Output (1));
            Instance.Read (Universal_Address (Instance_Size - 2), Output (2));
            Test_Element_Property (Input = Output, "Writing bytes at the end of memory should work");

            begin
               Instance.Write (Input (1), Universal_Address (Instance_Size));
               Fail_Test ("Writing beyond the end of memory should raise an exception");
            exception
               when Illegal_Address => null;
            end;

            begin
               Instance.Read (Universal_Address (Instance_Size), Output (1));
               Fail_Test ("Reading beyond the end of memory should raise an exception");
            exception
               when Illegal_Address => null;
            end;
         end;
      end;

      -- Test word I/O
      declare
         type Word_Buffer is array (Positive range <>) of Data_Types.Word;
         Output : Word_Buffer (1 .. 2);
      begin
         -- At the beginning of memory
         declare
            Input : constant Word_Buffer (1 .. 2) := (42424, 24242);
         begin
            Instance.Write (Input (1), 0);
            Instance.Write (Input (2), 2);
            Instance.Read (0, Output (1));
            Instance.Read (2, Output (2));
            Test_Element_Property (Input = Output, "Writing words at the beginning of memory should work");
         end;

         -- At the end of memory (including out of bounds)
         declare
            Input : constant Word_Buffer (1 .. 2) := (64646, 46464);
         begin
            Instance.Write (Input (1), Universal_Address (Instance_Size - 2));
            Instance.Write (Input (2), Universal_Address (Instance_Size - 4));
            Instance.Read (Universal_Address (Instance_Size - 2), Output (1));
            Instance.Read (Universal_Address (Instance_Size - 4), Output (2));
            Test_Element_Property (Input = Output, "Writing words at the end of memory should work");

            begin
               Instance.Write (Input (1), Universal_Address (Instance_Size - 1));
               Fail_Test ("Writing beyond the end of memory should raise an exception");
            exception
               when Illegal_Address => null;
            end;

            begin
               Instance.Read (Universal_Address (Instance_Size - 1), Output (1));
               Fail_Test ("Reading beyond the end of memory should raise an exception");
            exception
               when Illegal_Address => null;
            end;
         end;
      end;

      -- Test doubleword I/O
      declare
         type Double_Word_Buffer is array (Positive range <>) of Data_Types.Double_Word;
         Output : Double_Word_Buffer (1 .. 2);
      begin
         -- At the beginning of memory
         declare
            Input : constant Double_Word_Buffer (1 .. 2) := (123456789, 246813579);
         begin
            Instance.Write (Input (1), 0);
            Instance.Write (Input (2), 4);
            Instance.Read (0, Output (1));
            Instance.Read (4, Output (2));
            Test_Element_Property (Input = Output, "Writing doublewords at the beginning of memory should work");
         end;

         -- At the end of memory (including out of bounds)
         declare
            Input : constant Double_Word_Buffer (1 .. 2) := (321987654, 129834765);
         begin
            Instance.Write (Input (1), Universal_Address (Instance_Size - 4));
            Instance.Write (Input (2), Universal_Address (Instance_Size - 8));
            Instance.Read (Universal_Address (Instance_Size - 4), Output (1));
            Instance.Read (Universal_Address (Instance_Size - 8), Output (2));
            Test_Element_Property (Input = Output, "Writing doublewords at the end of memory should work");

            begin
               Instance.Write (Input (1), Universal_Address (Instance_Size - 3));
               Fail_Test ("Writing beyond the end of memory should raise an exception");
            exception
               when Illegal_Address => null;
            end;

            begin
               Instance.Read (Universal_Address (Instance_Size - 3), Output (1));
               Fail_Test ("Reading beyond the end of memory should raise an exception");
            exception
               when Illegal_Address => null;
            end;
         end;
      end;

      -- Test quadword I/O
      declare
         type Quad_Word_Buffer is array (Positive range <>) of Data_Types.Quad_Word;
         Output : Quad_Word_Buffer (1 .. 2);
      begin
         -- At the beginning of memory
         declare
            Input : constant Quad_Word_Buffer (1 .. 2) := (16#FEDC_BA98_7654_3210#, 16#1357_9BDF_0246_8ACE#);
         begin
            Instance.Write (Input (1), 0);
            Instance.Write (Input (2), 8);
            Instance.Read (0, Output (1));
            Instance.Read (8, Output (2));
            Test_Element_Property (Input = Output, "Writing quadwords at the beginning of memory should work");
         end;

         -- At the end of memory (including out of bounds)
         declare
            Input : constant Quad_Word_Buffer (1 .. 2) := (16#2468_ACE0_1357_9BDF#, 16#DEAD_BEEF_BADB_0053#);
         begin
            Instance.Write (Input (1), Universal_Address (Instance_Size - 8));
            Instance.Write (Input (2), Universal_Address (Instance_Size - 16));
            Instance.Read (Universal_Address (Instance_Size - 8), Output (1));
            Instance.Read (Universal_Address (Instance_Size - 16), Output (2));
            Test_Element_Property (Input = Output, "Writing quadwords at the end of memory should work");

            begin
               Instance.Write (Input (1), Universal_Address (Instance_Size - 7));
               Fail_Test ("Writing beyond the end of memory should raise an exception");
            exception
               when Illegal_Address => null;
            end;

            begin
               Instance.Read (Universal_Address (Instance_Size - 7), Output (1));
               Fail_Test ("Reading beyond the end of memory should raise an exception");
            exception
               when Illegal_Address => null;
            end;
         end;
      end;

      -- Test 128-bit I/O
      declare
         subtype SIMD128 is Data_Types.Two_Quad_Words;
         type SIMD128_Buffer is array (Positive range <>) of SIMD128;
         Output : SIMD128_Buffer (1 .. 2);
      begin
         -- At the beginning of memory
         declare
            Input : constant SIMD128_Buffer (1 .. 2) := ((16#9841_1651_6987_3689#, 16#9473_3489_3646_9473#),
                                                         (16#3469_7463_4639_1026#, 16#0426_3644_1296_0017#));
         begin
            Instance.Write (Input (1), 0);
            Instance.Write (Input (2), 16);
            Instance.Read (0, Output (1));
            Instance.Read (16, Output (2));
            Test_Element_Property (Input = Output, "Writing two-quadwords at the beginning of memory should work");
         end;

         -- At the end of memory (including out of bounds)
         declare
            Input : constant SIMD128_Buffer (1 .. 2) := ((16#7996_6423_9847_1234#, 16#9745_5494_1664_ABCD#),
                                                         (16#ABCD_EF94_2161_0633#, 16#9461_BC66_1664_6412#));
         begin
            Instance.Write (Input (1), Universal_Address (Instance_Size - 16));
            Instance.Write (Input (2), Universal_Address (Instance_Size - 32));
            Instance.Read (Universal_Address (Instance_Size - 16), Output (1));
            Instance.Read (Universal_Address (Instance_Size - 32), Output (2));
            Test_Element_Property (Input = Output, "Writing two-quadwords at the end of memory should work");

            begin
               Instance.Write (Input (1), Universal_Address (Instance_Size - 15));
               Fail_Test ("Writing beyond the end of memory should raise an exception");
            exception
               when Illegal_Address => null;
            end;

            begin
               Instance.Read (Universal_Address (Instance_Size - 15), Output (1));
               Fail_Test ("Reading beyond the end of memory should raise an exception");
            exception
               when Illegal_Address => null;
            end;
         end;
      end;

      -- Test 256-bit I/O
      declare
         subtype SIMD256 is Data_Types.Four_Quad_Words;
         type SIMD256_Buffer is array (Positive range <>) of SIMD256;
         Output : SIMD256_Buffer (1 .. 2);
      begin
         -- At the beginning of memory
         declare
            Input : constant SIMD256_Buffer (1 .. 2) := ((16#ABCD_EF94_2161_0633#, 16#9461_BC66_1664_6412#, 16#7996_6423_9847_1234#, 16#9745_5494_1664_EF01#),
                                                         (16#3469_7463_4639_1026#, 16#0426_3644_1296_0017#, 16#9841_1651_6987_3689#, 16#9473_3489_3646_9473#));
         begin
            Instance.Write (Input (1), 0);
            Instance.Write (Input (2), 32);
            Instance.Read (0, Output (1));
            Instance.Read (32, Output (2));
            Test_Element_Property (Input = Output, "Writing four-quadwords at the beginning of memory should work");
         end;

         -- At the end of memory (including out of bounds)
         declare
            Input : constant SIMD256_Buffer (1 .. 2) := ((16#6894_1967_A261_CD26#, 16#1494_FB16_5649_0644#, 16#ACD1_2644_0694_1144#, 16#6649_6265_1669_46FD#),
                                                         (16#1611_8218_4648_DDFA#, 16#9751_3140_9751_BCDF#, 16#6746_1721_9865_4216#, 16#5496_4658_4651_654E#));
         begin
            Instance.Write (Input (1), Universal_Address (Instance_Size - 32));
            Instance.Write (Input (2), Universal_Address (Instance_Size - 64));
            Instance.Read (Universal_Address (Instance_Size - 32), Output (1));
            Instance.Read (Universal_Address (Instance_Size - 64), Output (2));
            Test_Element_Property (Input = Output, "Writing four-quadwords at the end of memory should work");

            begin
               Instance.Write (Input (1), Universal_Address (Instance_Size - 31));
               Fail_Test ("Writing beyond the end of memory should raise an exception");
            exception
               when Illegal_Address => null;
            end;

            begin
               Instance.Read (Universal_Address (Instance_Size - 31), Output (1));
               Fail_Test ("Reading beyond the end of memory should raise an exception");
            exception
               when Illegal_Address => null;
            end;
         end;
      end;

      -- Test single precision float I/O
      declare
         type Float_Single_Buffer is array (Positive range <>) of Data_Types.Float_Single;
         Output : Float_Single_Buffer (1 .. 2);
      begin
         -- At the beginning of memory
         declare
            Input : constant Float_Single_Buffer (1 .. 2) := (42.42, 12.34);
         begin
            Instance.Write (Input (1), 0);
            Instance.Write (Input (2), 4);
            Instance.Read (0, Output (1));
            Instance.Read (4, Output (2));
            Test_Element_Property (Input = Output, "Writing single-precision floats at the beginning of memory should work");
         end;

         -- At the end of memory (including out of bounds)
         declare
            Input : constant Float_Single_Buffer (1 .. 2) := (76.54, 32.18);
         begin
            Instance.Write (Input (1), Universal_Address (Instance_Size - 4));
            Instance.Write (Input (2), Universal_Address (Instance_Size - 8));
            Instance.Read (Universal_Address (Instance_Size - 4), Output (1));
            Instance.Read (Universal_Address (Instance_Size - 8), Output (2));
            Test_Element_Property (Input = Output, "Writing single-precision floats at the end of memory should work");

            begin
               Instance.Write (Input (1), Universal_Address (Instance_Size - 3));
               Fail_Test ("Writing beyond the end of memory should raise an exception");
            exception
               when Illegal_Address => null;
            end;

            begin
               Instance.Read (Universal_Address (Instance_Size - 3), Output (1));
               Fail_Test ("Reading beyond the end of memory should raise an exception");
            exception
               when Illegal_Address => null;
            end;
         end;
      end;

      -- TODO : Test double precision float I/O
      declare
         type Float_Double_Buffer is array (Positive range <>) of Data_Types.Float_Double;
         Output : Float_Double_Buffer (1 .. 2);
      begin
         -- At the beginning of memory
         declare
            Input : constant Float_Double_Buffer (1 .. 2) := (123.4567, 890.1234);
         begin
            Instance.Write (Input (1), 0);
            Instance.Write (Input (2), 8);
            Instance.Read (0, Output (1));
            Instance.Read (8, Output (2));
            Test_Element_Property (Input = Output, "Writing double-precision floats at the beginning of memory should work");
         end;

         -- At the end of memory (including out of bounds)
         declare
            Input : constant Float_Double_Buffer (1 .. 2) := (567.8901, 234.5678);
         begin
            Instance.Write (Input (1), Universal_Address (Instance_Size - 8));
            Instance.Write (Input (2), Universal_Address (Instance_Size - 16));
            Instance.Read (Universal_Address (Instance_Size - 8), Output (1));
            Instance.Read (Universal_Address (Instance_Size - 16), Output (2));
            Test_Element_Property (Input = Output, "Writing double-precision floats at the end of memory should work");

            begin
               Instance.Write (Input (1), Universal_Address (Instance_Size - 7));
               Fail_Test ("Writing beyond the end of memory should raise an exception");
            exception
               when Illegal_Address => null;
            end;

            begin
               Instance.Read (Universal_Address (Instance_Size - 7), Output (1));
               Fail_Test ("Reading beyond the end of memory should raise an exception");
            exception
               when Illegal_Address => null;
            end;
         end;
      end;

      -- Test extended precision float I/O (with 128-bit alignment)
      declare
         type Float_Extended_Buffer is array (Positive range <>) of Data_Types.Float_Extended;
         Output : Float_Extended_Buffer (1 .. 2);
      begin
         -- At the beginning of memory
         declare
            Input : constant Float_Extended_Buffer (1 .. 2) := ((Fraction => 16#1691_6533_ABC2_6513#, Integer_Bit => False, Exponent => 16#2568#, Sign_Bit => True),
                                                                (Fraction => 16#7615_6161_6135_2137#, Integer_Bit => False, Exponent => 16#5313#, Sign_Bit => False));
         begin
            Instance.Write (Input (1), 0);
            Instance.Write (Input (2), 16);
            Instance.Read (0, Output (1));
            Instance.Read (16, Output (2));
            Test_Element_Property (Input = Output, "Writing extended-precision floats at the beginning of memory should work");
         end;

         -- At the end of memory (including out of bounds)
         declare
            Input : constant Float_Extended_Buffer (1 .. 2) := ((Fraction => 16#7496_1616_1312_4163#, Integer_Bit => False, Exponent => 16#6414#, Sign_Bit => True),
                                                                (Fraction => 16#3156_3161_4651_6514#, Integer_Bit => False, Exponent => 16#3541#, Sign_Bit => False));
         begin
            Instance.Write (Input (1), Universal_Address (Instance_Size - 16));
            Instance.Write (Input (2), Universal_Address (Instance_Size - 32));
            Instance.Read (Universal_Address (Instance_Size - 16), Output (1));
            Instance.Read (Universal_Address (Instance_Size - 32), Output (2));
            Test_Element_Property (Input = Output, "Writing extended-precision floats at the end of memory should work");

            begin
               Instance.Write (Input (1), Universal_Address (Instance_Size - 15));
               Fail_Test ("Writing beyond the end of memory should raise an exception");
            exception
               when Illegal_Address => null;
            end;

            begin
               Instance.Read (Universal_Address (Instance_Size - 15), Output (1));
               Fail_Test ("Reading beyond the end of memory should raise an exception");
            exception
               when Illegal_Address => null;
            end;
         end;
      end;

      -- Test asynchronous memory transfers
      declare
         use type Byte_Buffers.Byte_Buffer, Byte_Buffers.Byte_Buffer_Index;
         Input : constant Byte_Buffer_Handle := Byte_Buffers.Make_Byte_Buffer (Min_Index => 3,
                                                                               Max_Index => Byte_Buffer_Size (Instance_Size + 2));
         Copy_Process_Handle : Process_Handle;
      begin
         -- Initialize a shared input buffer that is as large as guest memory
         for I in Input.Target'Range loop
            Input.Target (I) := Data_Types.Byte ((3 * I + 1) mod 256);
         end loop;

         -- Try to send it to guest memory and fetch it back
         declare
            Output : constant Byte_Buffer_Handle := Byte_Buffers.Make_Byte_Buffer (Min_Index => 5,
                                                                                   Max_Index => Byte_Buffer_Size (Instance_Size + 4));
         begin
            -- Try to round trip our input buffer between host and guest
            select
               -- Give our tasks 1s to perform the memory copy
               delay 1.0;
               Fail_Test ("Memory copies are taking too long, memory manager probably hung");
            then abort
               -- Perform a memory round trip
               Instance.Start_Copy (Input           => Input,
                                    Output_Location => 0,
                                    Byte_Count      => Instance_Size,
                                    Process         => Copy_Process_Handle);
               Copy_Process_Handle.Target.Wait_For_Completion;
               Instance.Start_Copy (Input_Location => 0,
                                    Output         => Output,
                                    Byte_Count     => Instance_Size,
                                    Process        => Copy_Process_Handle);
               Copy_Process_Handle.Target.Wait_For_Completion;
            end select;

            -- Check that we got the same block of memory that we initially sent
            Test_Element_Property (Input.Target.all = Output.Target.all, "Full-memory copies should work as expected");
         end;

         -- Check that the memory subsystem rejects incorrect host/guest requests, such as writes that go beyond address space limits...
         begin
            Instance.Start_Copy (Input           => Input,
                                 Output_Location => 1,
                                 Byte_Count      => Instance_Size,
                                 Process         => Copy_Process_Handle);
            Fail_Test ("Out of bounds writes should be rejected at request time");
         exception
            when Illegal_Address => null;
         end;

         -- ...overflowing memory writes...
         declare
            Overly_Small_Input : constant Byte_Buffer_Handle := Byte_Buffers.Make_Byte_Buffer (Min_Index => 7,
                                                                                               Max_Index => Byte_Buffer_Size (Instance_Size - 7));
         begin
            Instance.Start_Copy (Input           => Overly_Small_Input,
                                 Output_Location => 0,
                                 Byte_Count      => Instance_Size,
                                 Process         => Copy_Process_Handle);
            Fail_Test ("Overflowing memory writes should be rejected at request time");
         exception
            when Byte_Buffers.Buffer_Overflow => null;
         end;

         -- ...and overflowing memory reads...
         declare
            Overly_Small_Output : constant Byte_Buffer_Handle := Byte_Buffers.Make_Byte_Buffer (Min_Index => 1,
                                                                                                Max_Index => Byte_Buffer_Size (Instance_Size - 1));
         begin
            Instance.Start_Copy (Input_Location => 0,
                                 Output         => Overly_Small_Output,
                                 Byte_Count     => Instance_Size,
                                 Process        => Copy_Process_Handle);
            Fail_Test ("Overflowing memory reads should be rejected at request time");
         exception
            when Byte_Buffers.Buffer_Overflow => null;
         end;

         -- Test internal memory transfers
         declare
            subtype Byte_Buffer_Index is Byte_Buffers.Byte_Buffer_Index;
            Half_Of_Memory : constant Universal_Size := Instance_Size / 2;
            Destination : constant Universal_Address := Universal_Address (Half_Of_Memory);
            Output : constant Byte_Buffer_Handle := Byte_Buffers.Make_Byte_Buffer (Byte_Buffer_Size (Half_Of_Memory));
            First_Input_Index : constant Byte_Buffer_Index := Input.Target.all'First;
         begin
            -- Copy the first half of memory to its second half
            select
               -- Give our tasks 1s to perform the memory copy
               delay 1.0;
               Fail_Test ("Memory copies are taking too long, memory manager probably hung");
            then abort
               -- Perform the internal copy, then check out its results
               Instance.Start_Copy (Input_Location  => 0,
                                    Output_Location => Destination,
                                    Byte_Count      => Half_Of_Memory,
                                    Process         => Copy_Process_Handle);
               Copy_Process_Handle.Target.Wait_For_Completion;
               Instance.Start_Copy (Input_Location => Destination,
                                    Output         => Output,
                                    Byte_Count     => Half_Of_Memory,
                                    Process        => Copy_Process_Handle);
               Copy_Process_Handle.Target.Wait_For_Completion;
            end select;

            -- Check that the copies went well
            Test_Element_Property (Input.Target (First_Input_Index .. First_Input_Index + Byte_Buffer_Size (Half_Of_Memory) - 1) = Output.Target.all,
                                   "Internal memory copies should work as expected");
         end;
      end;

      -- TODO : Test asynchronous byte streams
      Fail_Test ("This test suite is not extensive enough yet");
   end Test_Instance;

end Emulator_Kit.Memory.Abstract_Memory;
