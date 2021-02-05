using System;
using BarRaider.SdTools;
using System.Threading;

namespace streamdeck_commandline
{
    internal class Program
    {
        private static void Main(string[] args)
        {
#if DEBUG
            var seconds = 10;
            while (!System.Diagnostics.Debugger.IsAttached && seconds > 0)
            {
                Console.WriteLine($"Waiting for debugger to be attached ({seconds}s)...");
                Thread.Sleep(1000);
                seconds--;
            }
#endif

            SDWrapper.Run(args);
        }
    }
}
