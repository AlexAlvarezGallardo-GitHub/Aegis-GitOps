{{- define "reporting.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "reporting.fullname" -}}
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

{{- define "reporting.labels" -}}
helm.sh/chart: {{ include "reporting.name" . }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "reporting.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "reporting.selectorLabels" -}}
app.kubernetes.io/name: {{ include "reporting.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
