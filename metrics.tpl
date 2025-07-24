{{/* 
_dynatrace-helpers.tpl
Simplified Dynatrace Query Helpers for Response Time and 5xx Errors
*/}}

{{/*
Generate Dynatrace API URL
*/}}
{{- define "dynatrace.apiUrl" -}}
{{ .Values.dynatrace.baseUrl }}/api/v2/metrics/query
{{- end }}

{{/*
Generate Dynatrace authorization header
*/}}
{{- define "dynatrace.authHeader" -}}
{{- if .Values.secrets.dynatrace.enabled }}
valueFrom:
  secretKeyRef:
    name: {{ .Values.secrets.dynatrace.name }}
    key: {{ .Values.secrets.dynatrace.key }}
{{- else }}
value: "Api-Token {{ .Values.dynatrace.apiToken }}"
{{- end }}
{{- end }}

{{/*
Generate base Dynatrace web provider configuration
*/}}
{{- define "dynatrace.baseProvider" -}}
url: {{ include "dynatrace.apiUrl" . | quote }}
headers:
- key: "Authorization"
  {{- include "dynatrace.authHeader" . | nindent 2 }}
- key: "Content-Type"
  value: "application/json"
method: POST
{{- end }}

{{/*
Generate response time metric query
Usage: {{ include "dynatrace.responseTimeQuery" (dict "serviceId" "SERVICE-123" "timeRange" "10m" "resolution" "1m") }}
*/}}
{{- define "dynatrace.responseTimeQuery" -}}
{
  "metricSelector": "builtin:service.response.time:merge(\"dt.entity.service\"):filter(eq(\"dt.entity.service\",\"{{ .serviceId }}\"))",
  "resolution": "{{ .resolution | default "1m" }}",
  "from": "now-{{ .timeRange | default "10m" }}",
  "to": "now"
}
{{- end }}

{{/*
Generate 5xx error count metric query
Usage: {{ include "dynatrace.error5xxQuery" (dict "serviceId" "SERVICE-123" "timeRange" "10m" "resolution" "1m") }}
*/}}
{{- define "dynatrace.error5xxQuery" -}}
{
  "metricSelector": "builtin:service.errors.server.count:merge(\"dt.entity.service\"):filter(eq(\"dt.entity.service\",\"{{ .serviceId }}\"))",
  "resolution": "{{ .resolution | default "1m" }}",
  "from": "now-{{ .timeRange | default "10m" }}",
  "to": "now"
}
{{- end }}

{{/*
Generate metric analysis configuration
Usage: {{ include "dynatrace.metricConfig" (dict "successCondition" "result[0] < 1000" "failureLimit" 3) }}
*/}}
{{- define "dynatrace.metricConfig" -}}
successCondition: {{ .successCondition | quote }}
failureLimit: {{ .failureLimit | default 3 }}
interval: {{ .interval | default "60s" }}
count: {{ .count | default 5 }}
{{- end }}
