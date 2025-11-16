# Tarefa 17.0: Implementar Upload de Documentos (L)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Criar fluxo completo de seleção de foto (câmera ou galeria), compressão de imagem para otimizar upload, upload para backend e tracking de progresso. Usar PhotosPicker do iOS.

## Subtarefas

- [ ] 17.1 Criar `DocumentUploadFeature` com TCA
- [ ] 17.2 Implementar State com propriedades de upload
- [ ] 17.3 Implementar Actions para seleção, compressão e upload
- [ ] 17.4 Integrar PhotosPicker para seleção de imagens
- [ ] 17.5 Implementar seleção de câmera ou galeria
- [ ] 17.6 Implementar compressão de imagens (qualidade 0.7)
- [ ] 17.7 Implementar validação de limite (máximo 2 documentos)
- [ ] 17.8 Implementar upload com multipart/form-data
- [ ] 17.9 Implementar tracking de progresso de upload
- [ ] 17.10 Adicionar tratamento de erros de upload
- [ ] 17.11 Implementar retry em caso de falha
- [ ] 17.12 Adicionar validação de tipo de arquivo (apenas imagens)
- [ ] 17.13 Implementar validação de tamanho máximo
- [ ] 17.14 Testar com diferentes tamanhos e formatos de imagem

## Detalhes de Implementação

### Localização
- Arquivo: `Projects/Features/Negotiations/Sources/DocumentUploadFeature.swift`
- Criar novo arquivo

### Estrutura do Feature

```swift
@Reducer
public struct DocumentUploadFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedImages: [UIImage] = []
        public var compressedImages: [Data] = []
        public var uploadProgress: [String: Double] = [:] // documentId: progress
        public var isUploading: Bool = false
        public var errorMessage: String?
    }
    
    public enum Action: Equatable {
        case selectImages
        case imagesSelected([UIImage])
        case compressImages
        case uploadDocument(Data, String) // data, documentType
        case uploadProgress(String, Double) // documentId, progress
        case uploadCompleted(Result<NegotiationDocument, NetworkError>)
    }
}
```

### Compressão de Imagens

```swift
func compressImage(_ image: UIImage, quality: CGFloat = 0.7) -> Data? {
    return image.jpegData(compressionQuality: quality)
}
```

### Upload com Progresso

- Usar `URLSession.uploadTask` com delegate para tracking
- Ou implementar progress callback se NetworkService suportar
- Atualizar progress no state para exibir na UI

### Validações

- Máximo 2 documentos por negociação
- Apenas imagens (JPEG, PNG)
- Tamanho máximo (ex: 10MB antes de compressão)
- Verificar se documento já existe antes de upload

## Critérios de Sucesso

- [ ] Seleção de imagens funciona (câmera e galeria)
- [ ] Compressão reduz tamanho adequadamente
- [ ] Validação de limite funciona
- [ ] Upload funciona com multipart/form-data
- [ ] Progresso é rastreado e exibido
- [ ] Erros são tratados adequadamente
- [ ] Retry funciona em caso de falha
- [ ] Validações de tipo e tamanho funcionam
- [ ] Build do projeto compila sem erros

## Dependências

- **9.0**: Models devem estar criados
- **10.0**: NegotiationClient deve estar implementado
- **13.0**: NegotiationDetailFeature deve estar implementada

## Observações

- Usar `PhotosPicker` do SwiftUI (iOS 16+) ou `UIImagePickerController` (iOS 15)
- Compressão deve ser feita em background queue
- Considerar mostrar preview das imagens antes de upload

