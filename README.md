# practica-final-pss
En este repositorio encontraras la implementación de un chatbot para la creacion y mantenimiento de recursos de AWS
# 🚀 Plataforma de Automatización IaC + ChatOps  
**Terraform + Ansible + GitHub Actions + n8n + IA + Telegram**

Este proyecto implementa una plataforma completa orientada a DevOps/Platform Engineering que permite desplegar infraestructura en AWS mediante:
- Interacción natural por Telegram (ChatOps)
- Orquestación con n8n
- Infraestructura como código con Terraform
- Configuración con Ansible
- Ejecuciones auditadas con GitHub Actions
- Generación dinámica de código mediante IA (Ollama)

El usuario puede solicitar despliegues conversando con un bot, confirmar operaciones y ejecutar planes o configuraciones sin acceso directo a AWS.

---

## 🌩️ AWS Infra (Terraform)

Se trabaja con **backend remoto en S3 + DynamoDB**, asegurando:

✔ state compartido  
✔ locking  
✔ auditoría  
✔ idempotencia  

El backend está definido en `terraform/base_backend.tf` y **no puede ser modificado por IA.**

El código dinámico se genera en `terraform/generated.tf`.

---

## 🔐 Seguridad aplicada

### ✔ Control de identidad (Telegram)
Solo un usuario autorizado puede interactuar:
- Lista blanca por **usuario**
- Lista blanca por **chat**

### ✔ Aprobación obligatoria
Terraform Apply requiere:
- Terraform Plan visible por Telegram
- Aprobación explícita del usuario

### ✔ Auditoría en Git
Cada aprobación de Apply genera:
- Un archivo JSON en `audit/`
- Con usuario, fecha y acción

### ✔ Backend de estado inmutable
La IA no puede alterar:
- Bucket S3
- Key
- Región
- Tabla DynamoDB

---

## 🔁 Workflows implementados

### 🟩 Terraform Plan (plan inmutable)
- Se genera `tfplan`
- Se guarda como artifact
- Se muestra al usuario por Telegram

### 🟦 Terraform Apply
- Se descarga el mismo `tfplan`
- No recalcula cambios
- Aplica exactamente lo aprobado

### 🟨 Ansible
- Sin inventario permanente
- Las IPs se obtienen automáticamente desde Terraform Output
- Se inyectan en runtime

---

## 🧠 Generación dinámica por IA (Ollama)

El sistema genera:

- `.tf` → Infraestructura AWS
- `.yml` → Playbooks Ansible

Los prompts aplican restricciones estrictas:
- Sin Markdown
- Sin texto humano
- Sin inventar parámetros
- Variables obligatorias
- Tags estandarizadas
- Código válido

El backend no puede ser modificado por la IA.

---

## 📂 Estructura del proyecto


├── .github/workflows/ # GitHub CI/CD + Control Panel
├── ansible/ # Playbook generado y ejecutado
├── bootstrap/ # Infraestructura soporte (Bucket + Dynamo)
├── terraform/
│ ├── base_backend.tf # Backend fijo
│ └── generated.tf # Código IaC dinámico por IA
├── audit/ # Registros de aprobación (JSON)
└── README.md


---

## 🔍 Flujo de operación (end-to-end)

1. Usuario escribe en Telegram
2. n8n aplica reglas (seguridad, filtros)
3. IA genera Terraform/Ansible
4. n8n commitea a GitHub
5. GitHub Actions ejecuta Terraform Plan
6. Telegram pide aprobación
7. Si se aprueba → Terraform Apply con plan congelado
8. Se obtienen IPs dinámicas
9. Se ejecuta Ansible sobre los nodos

---

## 🛡️ Riesgos mitigados

- Backend protegido → no se corrompe el estado
- Aprobación obligatoria → no hay ejecución silenciosa
- Auditoría → cadena de responsabilidad
- Sin inventarios fijos → sin drift entre runs
- Plan inmutable → no hay recalculado no aprobado

---

## 📈 Futuras mejoras (propuestas profesionales)

No implementadas a propósito (solo roadmap):

- Validación de comandos por regex
- Doble aprobación (4-eyes principle)
- Rate limiting de usuarios
- MFA Telegram
- OIDC federado con AWS (sin access keys)
- Policies con OPA/Rego
- CMDB automática
- Tags financieras obligatorias
- Integración con Secrets Manager

Esto demuestra visión senior y escalabilidad futura.

---

## 🧪 Evaluación técnica (por qué este proyecto es completo)

Este proyecto demuestra:
- ChatOps real
- Control de infraestructura mediante IA
- Ciclo GitOps
- Idempotencia Terraform
- Seguridad mínima aplicada
- Auditoría trazable
- Automatización multi-herramienta
- Separación bootstrap vs proyectos reales

---

## 🏁 Conclusión

Este proyecto no es un script, sino una **plataforma operativa real**:

- desplegable
- auditable
- controlada
- extensible
- segura
- explicable en producción
- defendible ante auditoría

Es un ejemplo de **Platform Engineering aplicado con IA.**

---

## 📬 Contacto

> Proyecto académico — evaluación profesional  
Autor: *(tu nombre)*  
Telegram Bot: *(opcional)*
