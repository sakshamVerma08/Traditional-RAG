## README: Custom Retrieval-Augmented Generation (RAG) Pipeline 🚀

This project is a custom implementation of a complete **Retrieval-Augmented Generation (RAG) pipeline**. The primary motivation for building this was **for practice and learning**, following the concepts and structure demonstrated on **Krish Naik's YouTube channel**. It serves as a hands-on exercise in understanding the core components and flow of a RAG system, from data ingestion to augmented generation.

---


## The RAG Pipeline Thought Process: A Step-by-Step Breakdown

The RAG pipeline is conceptually divided into two main parts: the **Data Ingestion Pipeline** and the **Query Retrieval Pipeline**. The notebook, `pdf_loader.ipynb`, implements the code for each of these steps.

### 1. Data Ingestion Pipeline (From Raw Data to Vector Database)

This pipeline handles preparing the raw source documents for efficient retrieval. 
| Step | Description & Purpose | Code Implementation (Notebook Cells) |
| :--- | :--- | :--- |
| **A. Data Ingestion & Parsing** | **Goal:** Read raw files (e.g., PDFs) and convert them into a structured format (LangChain `Document` objects). | `process_documents` function: Uses `PyPDFLoader` to load PDFs and adds essential metadata like `source_file` and `file_type`. |
| **B. Document Splitting/Chunking** | **Goal:** Break down large documents into smaller, manageable chunks. This is crucial because smaller chunks lead to more relevant retrieval for specific questions and ensure the context fits within the LLM's **context window** (as noted in the first diagram). | `split_documents` function: Uses `RecursiveCharacterTextSplitter` with defined `chunk_size` (1000) and `chunk_overlap` (200) for effective contextual splitting. |
| **C. Embedding Generation** | **Goal:** Convert the textual chunks into **numerical vectors** (embeddings). This allows for semantic similarity search. | `EmbeddingsManager` class: Loads the **SentenceTransformer** model (`all-MiniLM-L6-V2`) to generate dense vector representations of the text chunks. |
| **D. Vector Store Initialization & Storage** | **Goal:** Store the text chunks, their metadata, and their corresponding embeddings in a persistent database for fast searching. | `VectorStore` class: Initializes a **ChromaDB** client (`PersistentClient`) and a collection. The `add_documents` method is used to insert the generated `embeddings`, `documents_text`, and `metadatas` into the Chroma collection. |

---

### 2. Query Retrieval & Augmented Generation Pipeline (The RAG Loop)

This pipeline handles a user's query, finds the relevant context, and uses it to generate an informed response. 
| Step | Description & Purpose | Code Implementation (Notebook Cells) |
| :--- | :--- | :--- |
| **A. User Query & Embedding** | **Goal:** Receive the user's question, and just like the source documents, convert it into an embedding vector. | `RAGRetriever.retrieve` method: Takes the `query` string and uses the `embeddings_manager` to generate a single query embedding vector. |
| **B. Retrieval from Vector Store** | **Goal:** Find the most semantically similar text chunks to the query vector. This is done using a **Similarity Search** (e.g., cosine similarity) in the Vector DB. | `RAGRetriever.retrieve` method: Calls `self.vector_store.collection.query` with the query embedding, requesting the `top_k` (default 5) most similar documents (chunks). The distance metric is converted to a `similarity_score` ($\text{score} = 1 - \text{distance}$). |
| **C. Context Augmentation** | **Goal:** Bundle the retrieved, relevant text chunks to serve as **external context** for the Large Language Model (LLM). | `simple_rag_function`: Extracts the `page_content` from the retrieved documents and joins them into a single `context` string. |
| **D. Augmented Generation (LLM)** | **Goal:** Feed the original user **Question** and the gathered **Context** into the LLM to generate a final, grounded answer. | `simple_rag_function`: Constructs a **prompt** that explicitly instructs the LLM (**Groq's Llama-3.1-8b-instant**) to answer *only* using the provided context, preventing the model from hallucinating or relying on its general knowledge. |

---

**Summary:** This RAG architecture successfully connects the data ingestion process with a dynamic retrieval system, culminating in a simple, context-aware question-answering function. This setup ensures that the LLM's responses are grounded in the specific, domain-knowledge documents loaded into the vector store.
