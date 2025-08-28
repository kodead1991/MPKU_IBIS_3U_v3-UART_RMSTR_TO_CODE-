from graphviz import Digraph
import os

# Добавьте эту строку ПЕРЕД созданием диаграммы
os.environ["PATH"] += os.pathsep + 'C:/Program Files/Graphviz/bin/'

# =====================
# Создаем новую диаграмму
# =====================
dot = Digraph(comment='UART Module Schematic')
dot.attr(rankdir='LR')

# =====================
# Добавляем блоки (узлы)
# =====================
dot.node('UART', 'UART_TX_BLOCK\n\nPorts:\ni_Clk, i_TxDV, i_Data\no_TX, o_TX_Active, o_Ready')
dot.node('DPRAM', 'DPRAM_2k\n\nPorts:\ndata, wraddress, wren\nrdaddress, rden, q')
dot.node('TXDATA', 'UART_TXDATA_BLOCK\n\nPorts:\ni_Clk, i_TxStart, i_TxHead\ni_RamData, o_RamRE, o_RamAddr')

# =====================
# Добавляем соединения
# =====================
dot.edge('TXDATA', 'DPRAM', label='o_RamRE -> rden\no_RamAddr -> rdaddress')
dot.edge('DPRAM', 'TXDATA', label='q -> i_RamData')
dot.edge('TXDATA', 'UART', label='o_DV -> i_TxDV\no_TxData -> i_Data')

# =====================
# Сохраняем БЕЗ автоматического просмотра
# =====================
dot.render('uart_schematic', format='png', view=False)
print("Схема создана: uart_schematic.png")

# Ручное открытие файла
import subprocess
subprocess.Popen(['start', 'uart_schematic.png'], shell=True)