; Script:    Vis2.ahk
; Author:    iseahound
#include <Gdip_All>

OCR(image:="", language:="", options:=""){
   return Vis2.OCR(image, language, options)
}

class Vis2 {


   class OCR extends Vis2.functor {
      call(self, image:="", language:="", options:=""){
         return (image != "") ? (new Vis2.provider.Tesseract()).OCR(image, language, options)
            : Vis2.core.returnText({"provider":(new Vis2.provider.Tesseract(language))})
      }
   }

   class functor {

      __Call(method, ByRef arg := "", args*) {
      ; When casting to Call(), use a new instance of the "function object"
      ; so as to avoid directly storing the properties(used across sub-methods)
      ; into the "function object" itself.
      ; Thanks to coco for this code. Modified by iseahound.
         if IsObject(method)
            return (new this).Call(method, arg, args*)
         else if (method == "")
            return (new this).Call(arg, args*)
      }
   }

   class Graphics {

      static pToken, Gdip := 0

      Startup(){
         global pToken
         return Vis2.Graphics.pToken := (Vis2.Graphics.Gdip++ > 0) ? Vis2.Graphics.pToken : (pToken) ? pToken : Gdip_Startup()
      }

      Shutdown(){
         global pToken
         return Vis2.Graphics.pToken := (--Vis2.Graphics.Gdip <= 0) ? ((pToken) ? pToken : Gdip_Shutdown(Vis2.Graphics.pToken)) : Vis2.Graphics.pToken
      }
   }

   class provider {

      class Tesseract {

         static leptonica := A_ScriptDir "\bin\leptonica_util\leptonica_util.exe"
         static tesseract := A_ScriptDir "\bin\tesseract\tesseract.exe"
         static tessdata_best := A_ScriptDir "\bin\tesseract\tessdata_best"
         static tessdata_fast := A_ScriptDir "\bin\tesseract\tessdata_fast"

         uuid := Vis2.stdlib.CreateUUID()
         file := A_Temp "\Vis2_screenshot" this.uuid ".bmp"
         fileProcessedImage := A_Temp "\Vis2_preprocess" this.uuid ".tif"
         fileConvertedText := A_Temp "\Vis2_text" this.uuid ".txt"

         __New(language:=""){
            this.language := language
         }

         OCR(image, language:="", options:=""){
            this.language := language
            try {
               screenshot := Vis2.stdlib.toFile(image, this.file)
               this.preprocess(screenshot, this.fileProcessedImage)
               this.convert_best(this.fileProcessedImage, this.fileConvertedText)
               text := this.getText(this.fileConvertedText)
            } catch e {
               MsgBox, 16,, % "Exception thrown!`n`nwhat: " e.what "`nfile: " e.file
                  . "`nline: " e.line "`nmessage: " e.message "`nextra: " e.extra
            }
            finally {
               this.cleanup()
            }
            return text
         }

         cleanup(){
            FileDelete, % this.file
            FileDelete, % this.fileProcessedImage
            FileDelete, % this.fileConvertedText
         }

         convert(in:="", out:="", fast:=1){
            in := (in) ? in : this.fileProcessedImage
            out := (out) ? out : this.fileConvertedText
            fast := (fast) ? this.tessdata_fast : this.tessdata_best

            if !(FileExist(in))
               throw Exception("Input image for conversion not found.",, in)

            if !(FileExist(this.tesseract))
               throw Exception("Tesseract not found",, this.tesseract)

            static q := Chr(0x22)
            _cmd .= q this.tesseract q " --tessdata-dir " q fast q " " q in q " " q SubStr(out, 1, -4) q
            _cmd .= (this.language) ? " -l " q this.language q : ""
            _cmd := ComSpec " /C " q _cmd q
            RunWait % _cmd,, Hide

            if !(FileExist(out))
               throw Exception("Tesseract failed.",, _cmd)

            return out
         }

         convert_best(in:="", out:=""){
            return this.convert(in, out, 0)
         }

         convert_fast(in:="", out:=""){
            return this.convert(in, out, 1)
         }

         getPreprocessImage(){
            return this.fileProcessedImage
         }

         getText(in:="", lines:=""){
            in := (in) ? in : this.fileConvertedText

            if !(database := FileOpen(in, "r`n", "UTF-8"))
               throw Exception("Text file could not be found or opened.",, in)

            if (lines == "") {
               text := RegExReplace(database.Read(), "^\s*(.*?)\s*$", "$1")
               text := RegExReplace(text, "(?<!\r)\n", "`r`n")
            } else {
               while (lines > 0) {
                  data := database.ReadLine()
                  data := RegExReplace(data, "^\s*(.*?)\s*$", "$1")
                  if (data != "") {
                     text .= (text) ? ("`n" . data) : data
                     lines--
                  }
                  if (!database || database.AtEOF)
                     break
               }
            }
            database.Close()
            return text
         }

         getTextLines(lines){
            return this.read(, lines)
         }

         preprocess(in:="", out:=""){
            static ocrPreProcessing := 1
            static negateArg := 2
            static performScaleArg := 1
            static scaleFactor := 3.5

            in := (in != "") ? in : this.file
            out := (out != "") ? out : this.fileProcessedImage

            if !(FileExist(in))
               throw Exception("Input image for preprocessing not found.",, in)

            if !(FileExist(this.leptonica))
               throw Exception("Leptonica not found",, this.leptonica)

            static q := Chr(0x22)
            _cmd .= q this.leptonica q " " q in q " " q out q
            _cmd .= " " negateArg " 0.5 " performScaleArg " " scaleFactor " " ocrPreProcessing " 5 2.5 " ocrPreProcessing  " 2000 2000 0 0 0.0"
            _cmd := ComSpec " /C " q _cmd q
            RunWait, % _cmd,, Hide

            if !(FileExist(out))
               throw Exception("Preprocessing failed.",, _cmd)

            return out
         }
      }
   }

   class stdlib {

      toFile(image, outputFile:=""){
        Vis2.Graphics.Startup()
		pBitmap := Gdip_BitmapFromScreen(image.1 "|" image.2 "|" image.3 "|" image.4)
		Gdip_SaveBitmapToFile(pBitmap, outputFile)
		Gdip_DisposeImage(pBitmap)
         
         if !(FileExist(outputFile))
            throw Exception("Could not find source image.")

         Vis2.Graphics.Shutdown()
         return outputFile
      }
	  
	  CreateUUID() {
         VarSetCapacity(puuid, 16, 0)
         if !(DllCall("rpcrt4.dll\UuidCreate", "ptr", &puuid))
            if !(DllCall("rpcrt4.dll\UuidToString", "ptr", &puuid, "uint*", suuid))
               return StrGet(suuid), DllCall("rpcrt4.dll\RpcStringFree", "uint*", suuid)
         return ""
      }
   }
}
