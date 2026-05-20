# Azure Logic Apps XSLT Transformation

This repository is a learning project built while exploring **Azure Logic Apps** and different ways to transform data between JSON and XML formats.

The goal was to understand how Logic Apps can use **XSLT**, **Liquid templates**, HTTP triggers, batch processing, parallel loops, and structured error handling to support common integration scenarios.

## What This Project Covers

- JSON to JSON transformation using a Liquid map
- JSON to XML transformation using XSLT and Logic Apps Data Mapper style output
- XML to JSON transformation using XSLT
- XML to XML transformation using XSLT
- HTTP-triggered Logic App workflows
- Batch input processing with chunk-based payloads
- Parallel processing using `Foreach` concurrency
- Success, partial success, and error response handling
- Correlation IDs for tracing workflow execution

## Repository Structure

```text
.
+-- Artifacts/
|   +-- Maps/
|       +-- json-to-json-enterprise.liquid
|       +-- json-to-xml-enterprise.xslt
|       +-- xml-to-json-enterprise.xslt
|       +-- xml-to-xml-enterprise.xslt
+-- json-to-json-workflow/
|   +-- workflow.json
+-- json-to-xml-enterprise/
|   +-- workflow.json
+-- xml-json-workflow/
|   +-- workflow.json
+-- xml-xml-workflow/
|   +-- workflow.json
+-- connections.json
+-- host.json
+-- local.settings.json
```

## Transformation Examples

### JSON to JSON

Uses a Liquid template to reshape order data, enrich lines with product lookup values, calculate line totals, and assign discount tiers.

### JSON to XML

Uses XSLT 3.0 to convert JSON payloads into XML order batches with headers, line items, totals, summaries, and audit metadata.

### XML to JSON

Uses XSLT to read XML order payloads and output JSON with order totals, high-value order flags, line totals, and summary information.

### XML to XML

Uses XSLT 1.0 to transform a purchase order XML document into a delivery note XML document, including calculated line totals and a grand total.

## Key Learnings

While building this, I learned how Azure Logic Apps can be used as an integration layer for data transformation workflows. The project helped me understand how maps are referenced from workflows, how different transformation engines fit different scenarios, and how to structure a workflow for batch processing, validation, tracing, and error handling.

This was mainly a hands-on playground to connect the concepts together and get more comfortable with enterprise-style integration patterns.

## Tech Stack

- Azure Logic Apps
- XSLT 1.0 and XSLT 3.0
- Liquid templates
- JSON
- XML
