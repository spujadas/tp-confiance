using System;

public class GetRsaKeyContainerFilename {
    static void Main(string[] args) {
        if (args.Length == 0) {
            Console.WriteLine(
                "Syntax: GetRsaKeyContainerFilename <private key GUID>"
            ) ;
        }
        else {
            Console.WriteLine(
                RsaUtil.RsaKeyFileUtil.GetRsaKeyContainerFilename(
                    args[0], false
                )
            ) ;
        }
    }
}
