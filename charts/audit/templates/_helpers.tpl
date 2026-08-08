{{- define "audit.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "audit.fullname" -}}
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

{{- define "audit.labels" -}}
helm.sh/chart: {{ include "audit.name" . }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "audit.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "audit.selectorLabels" -}}
app.kubernetes.io/name: {{ include "audit.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
