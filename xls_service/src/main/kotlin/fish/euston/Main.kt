package fish.euston


import com.google.gson.Gson
import com.google.gson.JsonArray
import com.google.gson.JsonElement
import com.google.gson.JsonObject
import org.apache.poi.ss.usermodel.CellType
import org.apache.poi.ss.usermodel.WorkbookFactory
import java.io.File
import java.io.FileInputStream

fun parseFile(path: String): JsonElement {
  val inp = FileInputStream(path)
  val wb = WorkbookFactory.create(inp)
  val o = JsonArray()
  wb.sheetIterator().forEach { sheet ->
    val jsonSheet = JsonObject()
    val rows = JsonArray()
    sheet.rowIterator().forEach { row ->
      val jsonRow = JsonArray()
      row.cellIterator().forEach { cell ->
        when (cell.cellTypeEnum) {
          CellType._NONE,
          CellType.ERROR,
          CellType.BLANK,
          null -> jsonRow.add(null as JsonElement?)
          CellType.NUMERIC -> cell.numericCellValue
          CellType.STRING -> jsonRow.add(cell.stringCellValue.trim())
          CellType.FORMULA -> jsonRow.add(cell.stringCellValue.trim())
          CellType.BOOLEAN -> jsonRow.add(cell.booleanCellValue)
        }
      }
      rows.add(jsonRow)
    }
    jsonSheet.addProperty("name", sheet.sheetName)
    jsonSheet.add("rows", rows)
    o.add(jsonSheet)
  }

  return o
}

fun main(args: Array<String>) {
  var input: String?
  while (true) {
    input = readLine()
    if (input == null) {
      return
    }
    val inFile = input
    val outFile = input + "-out.json"
    try {
      val elem = parseFile(inFile)
      File(outFile).bufferedWriter().use {
        it.write(Gson().toJson(elem))
      }
      println("ok")
    } catch (error: Exception) {
      println(error.message?.replace("\n", " "))
    }
  }
}