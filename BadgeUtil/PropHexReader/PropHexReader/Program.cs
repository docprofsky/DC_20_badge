using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.IO.Ports;
using System.IO;

namespace PropHexReader
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

            long page;
            byte checksum;

            Console.Write("COM Port ? ");
            input = Console.ReadLine();
            portNum = long.Parse(input);

            Console.Write("Block ? ");
            input = Console.ReadLine();
            block = long.Parse(input);

            Console.Write("Filename ? ");
            filename = Console.ReadLine();

            portName = "COM" + portNum.ToString();

            block = 0;


            comm = new SerialPort(portName, 115200, Parity.None, 8, StopBits.One);
            comm.Open();

            BinaryWriter bw = new BinaryWriter(File.Open(filename, FileMode.Create));
            byte data;

            byte[] buf = new byte[1];
            buf[0] = (byte) block;
            comm.Write(buf, 0, 1);

            checksum = 0;

            for (page = 0; page < 256; page++)
            {
                Console.WriteLine("Reading page " + page.ToString());
                for (int i = 0; i < 128; i++)
                {
                    data = (byte)comm.ReadByte();
                    bw.Write(data);
                    if (i != 5)
                        checksum += data;
                }
            }

            comm.Close();

            Console.WriteLine("Checksum : " + checksum.ToString());
            Console.WriteLine("Complete");

        }
    }
}
