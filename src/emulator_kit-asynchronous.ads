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

with Ada.Exceptions;

-- This package hierarchy provides asynchronous communication primitives between emulator tasks
package Emulator_Kit.Asynchronous is

   -- Represents an interface to an asynchronous communication channel that may transmit exceptions from a server side to a client side.
   -- On the basic exception channel, exceptions are fatal : once an exception has occured, nothing good will ever come out of the channel.
   -- The rule of thumb for exceptions on other methods is that functions are exception-safe, but procedures and entries may raise exceptions.
   type Exception_Channel is protected interface;
   procedure Notify_Exception (Target : in out Exception_Channel; Server_Exception : Ada.Exceptions.Exception_Occurrence) is abstract;
   function Exception_Pending (Target : Exception_Channel) return Boolean is abstract;
   procedure Fetch_Exception (Target : in out Exception_Channel) is abstract;  -- Trigger an exception if one is active, otherwise nothing happens

   -- A synchronous exception channel is very much like a regular exception channel, except the server promises to wait for the client to fetch the exception.
   -- On these communication channels, exceptions are not fatal, that is, they do not invalidate the communication channel. Once a client has fetched the exception,
   -- the communication channel is reset to a valid state.
   type Synchronous_Exception_Channel is protected interface and Exception_Channel;

end Emulator_Kit.Asynchronous;
