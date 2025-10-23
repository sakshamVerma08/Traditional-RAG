# 🧠 RAG Evaluation Dataset

This repository contains multiple **PDF documents** and **prompt sets** designed to evaluate the quality, accuracy, and grounding of a Retrieval-Augmented Generation (RAG) system.

---

## 📁 Folder Structure

data/
│
├── pdf_files/
│ ├── aws_well_architected_framework.pdf
│ ├── aws_security_pillar.pdf
│ ├── apple_annual_report_2024.pdf
│ ├── nasa_artemis_overview.pdf
│ └── art_of_war.pdf
│
├── prompts/
│ ├── aws_prompts.jsonl
│ ├── apple_prompts.jsonl
│ ├── nasa_prompts.jsonl
│ ├── art_of_war_prompts.jsonl
│ └── generic_grounding_tests.jsonl
│
└── README.md



---

## ⚙️ Setup Instructions

### 1. Prepare Environment
Use any RAG framework (LangChain, LlamaIndex, Haystack, etc.).

Example (LangChain + ChromaDB):

```python
from langchain_community.document_loaders import PyPDFLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_chroma import Chroma
from langchain.embeddings import OpenAIEmbeddings

loader = PyPDFLoader("docs/aws_well_architected_framework.pdf")
docs = loader.load()

splitter = RecursiveCharacterTextSplitter(chunk_size=800, chunk_overlap=100)
chunks = splitter.split_documents(docs)

vectorstore = Chroma.from_documents(chunks, OpenAIEmbeddings())
