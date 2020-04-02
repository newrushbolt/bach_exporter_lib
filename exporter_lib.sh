#! /bin/bash

# You need 2 global variables to use this lib
#   - metrics_prefix
#     Prefix ll be added to all metric names, string
#     Example: metrics_prefix="my_exporter_prefix"
#
#   - metrics_array
#     Metrics receiver, array
#     Example: metrics_array=()

# exporter_add_metric example:
#   exporter_add_metric remote_fetched gauge "Number of remote backups successfully fetched via scp" "remote_host:$remote_host;" 1
#
# exporter_add_metric input options:
#   - $1
#     Metric name, string
#     Example "some_metric_name"
#
#   - $2
#     Metric type, "gauge" or "counter"
#     Example "gauge"
#
#   - $3
#     Metric description, string
#     Example "Number of numbers of something"
#
#   - $4
#     Metric labels struct, string pairs with ":" separator within pair and ";" separator between pairs
#     Example "label_one_name:label_one_value;label_two_name:label_two_value"
#     You cannot use any whitespace in label keys or values
#
#   - $5
#     Metric value, int or float
#     Example "1.488"
function exporter_add_metric() {
	metric_labels=()
	metric_name="${metrics_prefix}_${1}"
	metric_description=$3
	metric_value=$5
	metric_type=$2
	metric_labels_struct=$4
	for label_string in ${metric_labels_struct//;/ }
	do
		label_key="${label_string/:*/}"
		label_value="${label_string/*:/}"
		label_line="${label_key}=\"${label_value}\""
		metric_labels+=($label_line)
	done
	metric_labels_raw_line="${metric_labels[@]}"
	metric_labels_line="${metric_labels_raw_line// /,}"
	metric_line="# HELP $metric_name $metric_description
# TYPE $metric_name gauge
$metric_name{$metric_labels_line} $metric_value"
	metrics_array+=("$metric_line")
}

function exporter_show_metrics_and_exit() {
	printf "%s\n" "${metrics_array[@]}"
	exit 0
}
