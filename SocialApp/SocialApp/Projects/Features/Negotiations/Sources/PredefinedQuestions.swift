import Foundation

/// Perguntas pré-definidas organizadas por categoria
public struct PredefinedQuestion: Identifiable, Equatable {
    public let id: String
    public let text: String
    public let category: QuestionCategory
    
    public init(id: String = UUID().uuidString, text: String, category: QuestionCategory) {
        self.id = id
        self.text = text
        self.category = category
    }
}

public struct PredefinedQuestions {
    public static let all: [PredefinedQuestion] = [
        // Autenticidade
        PredefinedQuestion(text: "O ingresso é original?", category: .authenticity),
        PredefinedQuestion(text: "O ingresso tem algum dano ou rasura?", category: .authenticity),
        PredefinedQuestion(text: "Como posso verificar a autenticidade do ingresso?", category: .authenticity),
        PredefinedQuestion(text: "O ingresso possui QR code válido?", category: .authenticity),
        
        // Condições
        PredefinedQuestion(text: "Qual a validade do ingresso?", category: .conditions),
        PredefinedQuestion(text: "O ingresso pode ser transferido para outra pessoa?", category: .conditions),
        PredefinedQuestion(text: "Há alguma restrição de uso?", category: .conditions),
        PredefinedQuestion(text: "O ingresso permite reentrada no evento?", category: .conditions),
        
        // Entrega
        PredefinedQuestion(text: "Como será feita a entrega do ingresso?", category: .delivery),
        PredefinedQuestion(text: "Quando posso receber o ingresso?", category: .delivery),
        PredefinedQuestion(text: "Há custo adicional para entrega?", category: .delivery),
        PredefinedQuestion(text: "O ingresso será enviado digitalmente ou físico?", category: .delivery),
        
        // Pagamento
        PredefinedQuestion(text: "Qual a forma de pagamento aceita?", category: .payment),
        PredefinedQuestion(text: "Há possibilidade de desconto?", category: .payment),
        PredefinedQuestion(text: "O pagamento pode ser parcelado?", category: .payment),
        PredefinedQuestion(text: "Há taxa adicional no pagamento?", category: .payment),
        
        // Outros
        PredefinedQuestion(text: "Posso ver mais fotos do ingresso?", category: .other),
        PredefinedQuestion(text: "O ingresso inclui algum benefício adicional?", category: .other),
    ]
    
    public static func questions(for category: QuestionCategory) -> [PredefinedQuestion] {
        all.filter { $0.category == category }
    }
    
    public static var questionsByCategory: [QuestionCategory: [PredefinedQuestion]] {
        Dictionary(grouping: all, by: { $0.category })
    }
}

