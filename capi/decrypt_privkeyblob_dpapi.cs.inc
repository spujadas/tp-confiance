// Get C# source code from http://www.obviex.com/samples/dpapi.aspx, and replace
// the Main method of the DPAPITest class with the following

[STAThread]
static void Main(string[] args)
{
    try
    {
        string description;

        // private key blob
        // paste your your Base64-encoded encrypted private key blob below
        string encrypted = @"..." ;
        
        // Call DPAPI to decrypt data.
        string decrypted = DPAPI.Decrypt(   encrypted,
                                        out description);
        Console.WriteLine(decrypted) ;
    }
    catch (Exception ex)
    {
        while (ex != null)
        {
            Console.WriteLine(ex.Message);
            ex = ex.InnerException;
        }
    }
}
