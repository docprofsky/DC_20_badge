using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.IO;
using System.IO.Ports;


namespace PropHexWriter
{
    class Program
    {
        static void Main(string[] args)
        {
            SerialPort comm;

            string portName;
            long portNum;
            long block;
            string input;
            string filename;
            long pageIndex;

            byte inData;

            byte checksum;
            byte[] buf = new byte[1];

            if (args.Length < 1)
                return;

            Console.Write("COM Port ? ");
            input = Console.ReadLine();
            portNum = long.Parse(input);

            portName = "COM" + portNum.ToString();

            //filename = args[0];
            filename = "C:\\badge\\out.eeprom";


            comm = new SerialPort(portName, 115200, Parity.None, 8, StopBits.One);
            comm.Open();

            BinaryReader br = new BinaryReader(File.Open(filename, FileMode.Open));
            byte data;

            // Send the 100 code to start things off
            buf[0] = (byte)100;
            comm.Write(buf, 0, 1);

            for (pageIndex = 0; pageIndex < 256; pageIndex++)
            {
                inData = (byte)comm.ReadByte();
                Console.WriteLine("Writing page " + inData.ToString());

                for (int i = 0; i < 128; i++)
                {
                    data = br.ReadByte();
                    buf[0] = data;
                    comm.Write(buf, 0, 1);
                }
            }
            comm.Close();

            Console.WriteLine("Complete");
        }
    }
}
