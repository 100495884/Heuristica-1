# Conjuntos
set CLASES := {'Estandar', 'Leisure Plus', 'Business Plus'};
set AVIONES := {'AV1', 'AV2', 'AV3', 'AV4', 'AV5'};

# Parámetros
param precio{CLASES};
param equipaje{CLASES};
param asientos{AVIONES};
param capacidad{AVIONES};

# Restricciones mínimas por clase y avión
param min_billetes_leisure{AVIONES};
param min_billetes_business{AVIONES};

# Variables
var x{CLASES, AVIONES} >= 0, integer;  # Número de billetes vendidos

# Función objetivo: Maximizar el beneficio total
maximize Beneficio_Total:
    sum{c in CLASES, a in AVIONES} x[c, a] * precio[c];

# Restricciones
s.t. Restriccion_Asientos{a in AVIONES}:
    sum{c in CLASES} x[c, a] <= asientos[a];

s.t. Restriccion_Capacidad{a in AVIONES}:
    sum{c in CLASES} x[c, a] * equipaje[c] <= capacidad[a];

s.t. Restriccion_Min_Leisure{a in AVIONES}:
    x['Leisure Plus', a] >= min_billetes_leisure[a];

s.t. Restriccion_Min_Business{a in AVIONES}:
    x['Business Plus', a] >= min_billetes_business[a];

# Cálculo del 60% del total de asientos disponibles
param total_asientos := sum{a in AVIONES} asientos[a];

# Restricción de que los billetes "Estandar" sean al menos el 60% del total de asientos
s.t. Restriccion_Estandar_Total:
    sum{a in AVIONES} x['Estandar', a] >= 0.6 * total_asientos;

end;
