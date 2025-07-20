{{/*
Expand the name of the chart.
*/}}
{{- define "internal-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "internal-service.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "internal-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "internal-service.labels" -}}
helm.sh/chart: {{ include "internal-service.chart" . }}
{{ include "internal-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "internal-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "internal-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "internal-service.image" -}}
{{- $registry := .Values.image.registry -}}
{{- $name := .Values.image.repository -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion -}}
{{- if $registry -}}
  {{- printf "%s/%s:%s" $registry $name $tag -}}
{{- else -}}
  {{- printf "%s:%s" $name $tag -}}
{{- end -}}
{{- end -}}

{{- define "internal-service.hpa.apiVersion" -}}
{{- if and (semverCompare ">=1.23.0-0" .Capabilities.KubeVersion.Version) (.Capabilities.APIVersions.Has "autoscaling/v2") -}}
autoscaling/v2
{{- else if .Capabilities.APIVersions.Has "autoscaling/v2beta2" -}}
autoscaling/v2beta2
{{- else -}}
autoscaling/v1
{{- end -}}
{{- end }}

{{- define "internal-service.httpPort" -}}
{{- $defaultPort := .Values.service.port -}}
{{- range .Values.extraEnvs }}
  {{- if eq .name "HTTP_PORT" }}
    {{- $defaultPort = .value | int }}
  {{- end }}
{{- end }}
{{- $defaultPort }}
{{- end }}
