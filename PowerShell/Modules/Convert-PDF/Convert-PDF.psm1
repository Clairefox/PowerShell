function Convert-PDF () {
    <#
        .SYNOPSIS
        Convert-PDF parses a PDF file and saves it in a string array variable.

        .DESCRIPTION
        This script consumes one (1) PDF file at a time and parses it into a useable
        string array variable which can be further manipulated as needed.
        Each page of the PDF is on a separate index of the output array. For example,
        the first page of the PDF is stored at $pdfFile[0], the second page is at 
        $pdfFile[1], and so on.

        .INPUTS
        This script only accepts a fully-formed path to PDF file.

        .OUTPUTS
        This program returns a string array of the contents of the full PDF file.

        .EXAMPLE
        Convert-PDF "C:\Full File Path\Report.pdf"

        .NOTES
        I did not originally create this. A more limited copy of the original PdfParser
        was given to me by a coworker and I updated it and converted it to be a module
        rather than a separate script to call.
        
        iTextSharp files can be found at https://www.nuget.org/packages/iTextSharp/.

    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0,Mandatory = $true)]
        [string]$file
    )

    #Add-Type -Path "C:\...\itextsharp.dll" -PassThru | Select-Object -ExpandProperty Assembly | Select-Object -ExpandProperty FullName -Unique

    if (Test-Path $file) {
        $pdfReader = New-Object iTextSharp.text.pdf.PdfReader -ArgumentList $file
        ForEach ($page in (1..$pdfReader.NumberOfPages)) {
            #$strategy = [iTextSharp.text.pdf.parser.SimpleTextExtractionStrategy]
            #$PdfTextExtractor = [iTextSharp.text.pdf.parser.PdfTextExtractor]
            $currentText = [iTextSharp.text.pdf.parser.PdfTextExtractor]::GetTextFromPage(
                            $pdfReader, $page, [iTextSharp.text.pdf.parser.SimpleTextExtractionStrategy]::new())
            $UTF8 = New-Object System.Text.UTF8Encoding 
            $ASCII = New-Object System.Text.ASCIIEncoding
            $EndText = $UTF8.GetString($ASCII::Convert(
                        [System.Text.Encoding]::Default, 
                        [System.Text.Encoding]::UTF8, 
                        [System.Text.Encoding]::DEFAULT.GetBytes($currentText)))
            $EndText
        } #end for loop
        $pdfReader.Close()
    } #if

    return $pdfFile
} #function