{{- define "fraud.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "fraud.fullname" -}}
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

{{- define "fraud.labels" -}}
helm.sh/chart: {{ include "fraud.name" . }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "fraud.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "fraud.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fraud.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
