"""Main entry point for the Investment Tracker application."""

import streamlit as st


def main() -> None:
    """Run the Streamlit application."""
    st.set_page_config(
        page_title="Investment Tracker",
        page_icon="💰",
        layout="wide",
    )

    st.title("💰 Investment Tracker")
    st.markdown("---")

    st.header("Welcome to your Investment Tracker!")
    st.write("This is a placeholder for the future dashboard.")

    st.sidebar.success("Select a page above.")

    # Example of using plotly later
    st.info("Features coming soon: Portfolio overview, Asset allocation, Performance tracking.")


if __name__ == "__main__":
    main()
