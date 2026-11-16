//
//  Model.swift
//  PostReader
//
//  Created by Ярослав on 16.11.2026.
//

import Foundation


enum GetJSONResult: Error {
    case fileNotFound
    case emptyInputForURL
    case emptyDataForSave

//    case folderError(Error)             // хранит дополнительную информацию - исходную ошибку (значение Error будет тоже учит) - сможем потом разобрать эту доп инфу
    // case encodingError(Error)
    // case saveError(Error)
    case loadError(Error)
    case decodingError(Error)
}


let url = Bundle.main.url(
    forResource: "array",
    withExtension: "json"
)

struct ourModel: Identifiable, Codable {
    let userID: Int
    let id: Int
    var title: String
    var body: String
}



func loadJSON(whereWeGet: URL) throws -> [ourModel] {
    let data: Data
    
    do {
        data = try Data(contentsOf: whereWeGet)                                     // пытаемся грузануть дату
    } catch let error as CocoaError where error.code == .fileReadNoSuchFile {       // если файла пока нет(код ошибки говорит об этом) - то пуст м создаем
        let newArrayOfModels: [ourModel] = []
        return newArrayOfModels
    } catch {
        throw GetJSONResult.loadError(error)
    }
    
    if data.isEmpty {
        throw GetJSONResult.emptyInputForURL
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode([ourModel].self, from: data)
    } catch {
        throw GetJSONResult.decodingError(error)
    }
}


func program() -> [ourModel] {
    do {
        if let ourURL = url {
            var array = try loadJSON(whereWeGet: ourURL)
            return array
        }
    } catch {
        switch error {
        case GetJSONResult.fileNotFound:
            print("we can't find file")
            
        case GetJSONResult.emptyInputForURL:
            print("input for URL is empty")
        
        case GetJSONResult.decodingError(let cause):                           // есть ошибки декодирования - мы разбираем случ-какие они могут быть
            switch cause {
                case DecodingError.typeMismatch(_, _):
                print("Несоответствие типов")

                case DecodingError.dataCorrupted(let context):                                      // context = сведения об ошибке
                print("Некорректные данные: \(context.debugDescription)")

                default:
                print("Другая причина: \(cause)")
        }
        default:
            print("we don't know this type of error")
        }
    }
    return []
}


func start() {
    var array = program()
    var count = 1
    for currentModel in array {
        if currentModel.userID == 2 && currentModel.id == 101 && currentModel.title == "Second" && currentModel.body == "Doumbia" && count == 1 {
            print("первая модель прошла проверку")
        }
        count += 1
    }
}


