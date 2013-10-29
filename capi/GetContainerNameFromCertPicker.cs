using System;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;

class GetContainerNameFromCertPicker {
    static void Main() {
        try {
            X509Store store = new X509Store("MY",StoreLocation.CurrentUser);
            store.Open(OpenFlags.ReadOnly | OpenFlags.OpenExistingOnly);
            X509Certificate2Collection collection =
                X509Certificate2UI.SelectFromCollection(
                    (X509Certificate2Collection)store.Certificates,
                    "Certificate selection",
                    "Select a certificate to obtain the container name from",
                    X509SelectionFlag.SingleSelection);
            
            if (collection.Count == 1) {
                X509Certificate2 x509 = collection[0] ;
                Console.WriteLine("Subject: {0}", x509.Subject) ;
                Console.WriteLine("Friendly name: {0}", x509.FriendlyName) ;
                if (x509.PrivateKey != null) {
                    ICspAsymmetricAlgorithm pkey = x509.PrivateKey
                        as ICspAsymmetricAlgorithm ;
                    Console.WriteLine("Key container name: {0}",
                        pkey.CspKeyContainerInfo.KeyContainerName);
                }
                x509.Reset();
            }
            store.Close();
        }
        catch (Exception e) {
           Console.WriteLine(e.ToString()) ;
        }
    }
}

