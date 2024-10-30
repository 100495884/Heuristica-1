# Conjuntos
set CLASES;  # Clases de billetes, e.g., {'Estandar', 'Leisure Plus', 'Business Plus'}
set AVIONES; # Aviones disponibles, e.g., {'AV1', 'AV2', ...}
set PISTAS;  # Pistas de aterrizaje
set SLOTS;   # Slots de tiempo

# Parámetros del problema de beneficios (Primera Parte)
param precio{CLASES};
param equipaje{CLASES};
param asientos{AVIONES};
param capacidad{AVIONES};
param min_billetes_leisure{AVIONES};
param min_billetes_business{AVIONES};

# Parámetros del problema de aterrizajes y retrasos (Segunda Parte)
param hora_llegada{AVIONES};
param hora_limite{AVIONES};
param coste_retraso{AVIONES} >= 0;
param posible_hora_llegada{SLOTS};
param disponibilidad{PISTAS, SLOTS}, binary;
param big_M;

# Variables del problema de beneficios (Primera Parte)
var x{CLASES, AVIONES} >= 0, integer;  # Número de billetes vendidos

# Variables del problema de aterrizajes (Segunda Parte)
var b{AVIONES, PISTAS, SLOTS}, binary; # Binaria para aterrizaje

# Función objetivo conjunta: maximizar el beneficio menos el coste de retraso
maximize Beneficio_Total:
    sum{c in CLASES, a in AVIONES} x[c, a] * precio[c]
    - sum{a in AVIONES, p in PISTAS, s in SLOTS} coste_retraso[a] * (posible_hora_llegada[s] - hora_llegada[a]) * b[a, p, s];

# Restricciones del problema de beneficios (Primera Parte)
s.t. Restriccion_Asientos{a in AVIONES}:
    sum{c in CLASES} x[c, a] <= asientos[a];

s.t. Restriccion_Capacidad{a in AVIONES}:
    sum{c in CLASES} x[c, a] * equipaje[c] <= capacidad[a];

s.t. Restriccion_Min_Leisure{a in AVIONES}:
    x['Leisure Plus', a] >= min_billetes_leisure[a];

s.t. Restriccion_Min_Business{a in AVIONES}:
    x['Business Plus', a] >= min_billetes_business[a];

s.t. Restriccion_Estandar_Total:
    sum{a in AVIONES} x['Estandar', a] >= 0.6 * sum{a in AVIONES} asientos[a];

# Restricciones del problema de aterrizajes y retrasos (Segunda Parte)
s.t. Unico_Slot_Por_Avion{a in AVIONES}:
    sum{p in PISTAS, s in SLOTS} b[a, p, s] = 1;

s.t. Unico_Avion_Por_Slot{p in PISTAS, s in SLOTS}:
    sum{a in AVIONES} b[a, p, s] <= 1;

s.t. Slot_Libre {a in AVIONES, p in PISTAS, s in SLOTS}:
    b[a, p, s] <= disponibilidad[p, s];

s.t. Llegada_Despues_Hora{a in AVIONES, p in PISTAS, s in SLOTS}:
    posible_hora_llegada[s] >= hora_llegada[a] - big_M * (1 - b[a,p,s]);

s.t. Limite_Tiempo{a in AVIONES, p in PISTAS, s in SLOTS}:
    posible_hora_llegada[s] <= hora_limite[a] + big_M * (1 - b[a,p,s]);

s.t. No_Slots_Consecutivos {a in AVIONES, p in PISTAS, s in 1..card(SLOTS)-1}:
    b[a,p,s] + b[a,p,s+1] <= 1;

end;
