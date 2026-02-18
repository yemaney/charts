{{/*
Common labels
*/}}
{{- define "dbt-workbench.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Resolve the secret name.
If secrets.create is true (or not set), use the chart-generated secret.
If secrets.existingSecretName is set, use that instead.
*/}}
{{- define "dbt-workbench.secretName" -}}
{{- if and (hasKey .Values.secrets "create") (not .Values.secrets.create) }}
{{- required "secrets.existingSecretName is required when secrets.create is false" .Values.secrets.existingSecretName }}
{{- else }}
{{- .Release.Name }}-secrets
{{- end }}
{{- end }}

