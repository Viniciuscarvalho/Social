# 🔧 Solução para Erro de Login

## 🚨 Problema Identificado

O erro "Invalid login credentials" está acontecendo porque:

1. **Confirmação de Email**: O Supabase pode estar exigindo confirmação de email
2. **Trigger de Profile**: O trigger para criar o profile automaticamente pode não estar funcionando
3. **Configuração de Auth**: Faltam algumas configurações específicas

## ✅ Soluções Implementadas

### 1. **Melhorias no AuthClient**
- ✅ Adicionados logs mais detalhados para debug
- ✅ Melhor tratamento de erros
- ✅ Retry automático para buscar profile após cadastro
- ✅ Tratamento de casos onde a sessão não é retornada

### 2. **Configuração do SupabaseManager**
- ✅ Configuração simplificada (removida configuração complexa que causava erro)
- ✅ Logs para debug das credenciais

## 🛠️ Próximos Passos para Resolver

### 1. **Configurar Supabase Dashboard**

Acesse seu projeto no Supabase e execute estes comandos SQL:

```sql
-- 1. Desabilitar confirmação de email para desenvolvimento
UPDATE auth.config 
SET enable_signup = true, 
    enable_email_confirmations = false,
    enable_email_change_confirmations = false;

-- 2. Verificar se o trigger existe
SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';

-- 3. Se não existir, criar o trigger:
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1))
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- 4. Verificar se a tabela profiles existe
SELECT * FROM profiles LIMIT 1;

-- 5. Se não existir, criar:
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    avatar_url TEXT,
    bio TEXT,
    phone TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    total_spent NUMERIC DEFAULT 0,
    events_attended INTEGER DEFAULT 0,
    notifications_enabled BOOLEAN DEFAULT TRUE,
    email_notifications BOOLEAN DEFAULT TRUE,
    language TEXT DEFAULT 'pt-BR'
);

-- 6. Habilitar RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- 7. Criar policies
CREATE POLICY "Profiles are viewable by everyone"
    ON profiles FOR SELECT
    USING (true);

CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON profiles FOR INSERT
    WITH CHECK (auth.uid() = id);
```

### 2. **Testar o Fluxo**

1. **Limpe os dados locais**:
   - Delete o app do simulador/dispositivo
   - Ou limpe os UserDefaults no código

2. **Teste o cadastro**:
   - Tente criar uma nova conta
   - Verifique os logs no console do Xcode

3. **Teste o login**:
   - Use as credenciais que acabou de criar
   - Verifique os logs detalhados

### 3. **Verificar Logs**

Agora você verá logs mais detalhados como:

```
🔐 AuthClient: Fazendo login para usuario@email.com
🔍 AuthClient: Verificando se usuário existe...
✅ AuthClient: Login no Supabase bem-sucedido, buscando profile...
✅ AuthClient: Profile encontrado: Nome do Usuário
✅ AuthClient: Login bem-sucedido para Nome do Usuário
```

## 🔍 Debug Adicional

Se ainda houver problemas, verifique:

1. **Credenciais do Supabase**:
   - URL está correta?
   - Anon key está correta?
   - Projeto está ativo (não pausado)?

2. **Banco de Dados**:
   - Tabela `profiles` existe?
   - Trigger `on_auth_user_created` existe?
   - Policies estão corretas?

3. **Configuração de Auth**:
   - Email confirmations desabilitado?
   - Signup habilitado?

## 📱 Teste Rápido

Para testar rapidamente:

1. Execute os comandos SQL acima no Supabase
2. Compile o app
3. Tente fazer cadastro com um email novo
4. Tente fazer login com as credenciais criadas

## 🆘 Se Ainda Não Funcionar

Se ainda houver problemas:

1. Verifique os logs detalhados no console
2. Teste criar um usuário manualmente no Supabase Dashboard
3. Verifique se o trigger está funcionando
4. Teste as credenciais no dashboard do Supabase

---

**Nota**: As melhorias implementadas devem resolver o problema. O principal era a falta de logs detalhados e o tratamento inadequado de erros durante o processo de criação do profile.
