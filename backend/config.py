from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    model_config = {"env_file": ".env", "env_file_encoding": "utf-8", "extra": "ignore"}

    database_url: str = "sqlite:///health_pilot.db"
    llm_model: str = "GLM-4.7"
    llm_api_key: str = ""
    llm_base_url: str = "https://open.bigmodel.cn/api/coding/paas/v4"
    
    # Vision LLM Configuration for Multi-modal features
    vision_llm_model: str = "qwen-vl-plus"
    vision_llm_api_key: str = ""
    vision_llm_base_url: str = "https://dashscope.aliyuncs.com/compatible-mode/v1"
    
    os_security_key: str = ""
    
    embedding_model: str = ""
    embedding_api_key: str = ""
    embedding_base_url: str = ""
    knowledge_dir: str = ""
    vector_db_dir: str = ""

    default_push_schedule: dict = {
        "breakfast_reminder": "07:30",
        "lunch_reminder": "11:30",
        "dinner_reminder": "17:30",
        "weigh_in_reminder": "08:00",
        "weekly_report": "Sunday 20:00",
    }

    protein_target_per_kg: float = 1.6
    default_target_rate_kg_per_week: float = 0.5


settings = Settings()
