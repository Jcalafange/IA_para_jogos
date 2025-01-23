# **Projeto de Inteligência Artificial para Jogos**

**Integrantes do Grupo:**
- Danilo de Souza Braga Aciole  
- João Vitor Calafange de Carvalho Lopes  

---

## **Descrição do Projeto**

Este projeto foi desenvolvido como parte da disciplina de **Inteligência Artificial para Jogos**, com o objetivo de implementar um sistema de inteligência artificial (IA) para inimigos. O sistema utiliza duas abordagens principais: **Behavior Trees** e **Steering Behaviors**. A IA é projetada para reagir dinamicamente ao estado atual do jogo, permitindo que os inimigos tomem decisões estratégicas e adaptativas.

---

## **Comportamentos do Inimigo**

O inimigo possui três possíveis objetivos principais, definidos com base em condições específicas do jogo:

### **1. Chase Player (Perseguir o Jogador)**  
- **Descrição:** O inimigo persegue o jogador até que este esteja a uma certa distância (dentro do alcance).  
- **Estado inicial:** O jogador está fora do alcance e o inimigo não precisa se curar.  
- **Estado desejado:** O jogador está dentro do alcance do inimigo.  

### **2. Heal (Curar-se)**  
- **Descrição:** Quando o inimigo perde uma certa quantidade de vida, ele busca uma área de cura para se recuperar.  
- **Estado inicial:** O inimigo precisa de cura.  
- **Estado desejado:** O inimigo não precisa mais de cura.  

### **3. Stay (Permanecer Parado)**  
- **Descrição:** O inimigo permanece parado e observa o jogador, sem realizar outras ações.  
- **Estado inicial:** O jogador está dentro do alcance do inimigo.  
- **Estado desejado:** O jogador saiu do alcance ou o inimigo recuperou um nível suficiente de vida.  

---

## **Ações do Inimigo**

Para atingir os objetivos definidos, o inimigo pode executar as seguintes ações:  

### **1. Chase Player (Perseguir o Jogador)**  
- **Descrição:** O inimigo segue o jogador até que ele esteja dentro do alcance.  

### **2. Chase Healer (Ir para a Área de Cura)**  
- **Descrição:** O inimigo se desloca até a área de cura para se recuperar.  

### **3. Stay (Ficar Parado)**  
- **Descrição:** O inimigo permanece imóvel, recuperando parte de sua vida enquanto está parado.  

### **4. Do Nothing (Ficar Observando)**  
- **Descrição:** O inimigo permanece parado observando o jogador, sem realizar nenhuma ação, até que o jogador saia do alcance.  

---
