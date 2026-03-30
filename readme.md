# Parâmetros
- camada de escavação C
- lista de itens pra manter no inventário
- limpar o inventário a cada X blocos
- refuelWithLava


# Loop
- cava até a camada C, começa a cavar pra frente
  - se bloco na frente é lava && refuelWithLava, reabastece
  - se encontra minério, mineVein()
  - ++dropItemsCounter
  - check de limpar inventário
  - check nível de combustível//inventário cheio


# Check de voltar
- se <combustível atual> + <threshold> <= distancia pra base: volta()
- se blocos minerados >= threshold: volta()
- se inventario quase cheio: volta()


# Função de voltar
- volta por baixo da terra pra evitar quebrar bloco


# Funções helper
- mineForward()
- mineBackward()
- mineTo()
