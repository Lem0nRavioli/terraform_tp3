from mlflow.tracking import MlflowClient

def get_latest_run_id(experiment_name="Default"):
    """
    Retrieve the latest run ID for a given experiment.
    """
    client = MlflowClient()
    experiment = client.get_experiment_by_name(experiment_name)
    if experiment:
        runs = client.search_runs(
            experiment_ids=[experiment.experiment_id],
            order_by=["start_time DESC"],
            max_results=1
        )
        if runs:
            return runs[0].info.run_id
    return None
