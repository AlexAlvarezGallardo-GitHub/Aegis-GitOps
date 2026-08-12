{{- define "payment.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "payment.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "payment.labels" -}}
helm.sh/chart: {{ include "payment.name" . }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "payment.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "payment.selectorLabels" -}}
app.kubernetes.io/name: {{ include "payment.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
