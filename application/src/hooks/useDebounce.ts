import { useState, useEffect } from "react";

/**
 * Debounces a value with the specified delay.
 * @param value - The value to debounce.
 * @param delay - Delay in milliseconds (default 300ms).
 * @returns Debounced value.
 */
export function useDebounce<T>(value: T, delay = 300): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}
