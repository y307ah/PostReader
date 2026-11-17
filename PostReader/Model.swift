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

    case loadError(Error)
    case decodingError(Error)
    case good([ourModel])
    case anotherError
}

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


let url = URL(
    fileURLWithPath: "/Users/aroslav/Documents/projects_swift/PostReader/PostReader/array.json"
)

func program() -> GetJSONResult {
    do {
        var array = try loadJSON(whereWeGet: url)
        return GetJSONResult.good(array)
    } catch {
        switch error {
        
        case GetJSONResult.fileNotFound:
            return GetJSONResult.fileNotFound
            
        case GetJSONResult.emptyDataForSave:
            return GetJSONResult.emptyDataForSave
        
        case GetJSONResult.emptyInputForURL:
            return GetJSONResult.emptyInputForURL
        
        case GetJSONResult.decodingError(let cause):                           // есть ошибки декодирования - мы разбираем случ-какие они могут быть
            switch cause {
                case DecodingError.typeMismatch(_, _):
                print("Несоответствие типов")

                case DecodingError.dataCorrupted(let context):                                      // context = сведения об ошибке
                print("Некорректные данные: \(context.debugDescription)")

                default:
                print("Другая причина: \(cause)")
            }
            return GetJSONResult.decodingError(cause)
        default:
            return GetJSONResult.anotherError
        }
    }
}


func start() {
    let returned = program()
    
    switch returned {
    
    case .fileNotFound:
        print("we can't find file")
    case .emptyInputForURL:
        print("input for URL is empty")
    case .emptyDataForSave:
        print("emptyDataForSave")
    case .loadError(let error):
        print("we have loadError - \(error)")
    case .decodingError(let error):
        print("we have decodingError - \(error)")
    case .good(let array):
        var count = 0
        for currentModel in array {
            if currentModel.userID == 2 && currentModel.id == 101 && currentModel.title == "Second" && currentModel.body == "Doumbia" && count == 0 {
                print("первая модель прошла проверку")
                count += 1
            }
            if currentModel.userID == 1 && currentModel.id == 202 && currentModel.title == "First" && currentModel.body == "Mebappe" && count == 1 {
                print("вторая модель прошла проверку")
                count += 1
            }
            
            if count == 2 {
                print("скок надо")
            }
        }
    case .anotherError:
        print("we don't know this type of error")
    }
}


